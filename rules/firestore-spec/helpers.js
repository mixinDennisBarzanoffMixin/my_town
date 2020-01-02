const firebase = require('@firebase/testing');
const fs = require('fs');

module.exports.setup = async (auth, data) => {
    const projectId = `rules-spec-${Date.now()}`;
    const app = firebase.initializeTestApp({
        projectId,
        auth
    });

    // Apply no rules
    await firebase.loadFirestoreRules({
        projectId,
        rules: fs.readFileSync(__dirname + '/../allow_all.rules', 'utf8')
    });

    const db = app.firestore();

    // Write mock documents before rules
    if (data) {
        for (const key in data) {
            const ref = db.doc(key);
            await ref.set(data[key]);
        }
    }



    // Apply rules
    await firebase.loadFirestoreRules({
        projectId,
        rules: fs.readFileSync(__dirname + '/../../firestore.rules', 'utf8')
    });

    return db;
};

module.exports.teardown = async () => {
    Promise.all(firebase.apps().map(app => app.delete()));
};


expect.extend({
    async toBeAllowed(x) {
        let pass = false;
        try {
            await firebase.assertSucceeds(x);
            pass = true;
        } catch (err) { }

        return {
            pass,
            message: () => 'Expected Firebase operation to be allowed, but it was denied'
        };
    }
});

expect.extend({
    async toBeDenied(x) {
        let pass = false;
        try {
            await firebase.assertFails(x);
            pass = true;
        } catch (err) { }
        return {
            pass,
            message: () =>
                'Expected Firebase operation to be denied, but it was allowed'
        };
    }
});