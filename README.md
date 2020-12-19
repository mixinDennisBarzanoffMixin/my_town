# My Town

## Build

    flutter run

## Introduction
The idea is to make an application that is useful for citizens which they
could use to report issues somewhere in real time. After that a municipality or
some cleaning company could see and fix it. The municipality could pay the
users for citizen control. Firebase, which has a fairly generous free tier, was
used for the realisation of the app.

fig 2.1 Application arcitecture
<img src="https://i.imgur.com/S04Z0FU.png" />

The application is made “non-profit”. Because managing a system like this one
isn’t free, there needs to be some sort of funding. This is because the
application itself cannot make money and consequently cannot exist without
being funded via non-profit municipalities, charities or donations.
Figure 2.1 shows the application infrastructure. The client side can be seen on
the left with blue. The communication between the applications and the
infrastructure is illustrated as well in it. The app communicates mainly with
Google Cloud, but there are dependencies outside Google as well.
The process of reporting an issue includes asking the user questions for
determining the type of issue, an image of it as well as a short description. If the

case is urgent to be dealt with, the app could contact emergency authorities via
their API. This way the municipalities could get away with problems such as
illegal construction, holes along the road, crime, fire, broken lighting, etc.
Another use case for the app could be using gathered user data for
evaluating the mayors and the services of the district, such as “100% for
lighting”.
Every user has an opportunity to stay anonymous until they wish
otherwise.
To stay anonymous, the user could login with their phone number and to
stop being anonymous, they could link a social media account of theirs sike
Facebook or Google. The phone number is unique per device, which allows to
tell users apart distinguish users, such that duplication of user actions is
avoided. The application should also support an AI in order to catch duplicated
reports by having it look at the pictures and/or description of the issue. For
example, if someone has written “Burning trash bin” and there already is a case
reported with a similar description, the application suggests the user to vote and
confirm that issue instead of submitting the same one once more. That way the
responsible authorities (the municipalities) can tell the more important cases
apart. If a user tries to abuse the system, they could be warned, and if they do
not cease, they could be banned.

<img src="https://i.imgur.com/C8mI5ct.png" />

Citizens have the opportunity to show themselves by getting feedback from
companies offering cleaning services.
Every user could get a reward in the form of appearance in the app for
reporting issues; for example, “most active citizen this month” or “in Sofia”. If a
user fixes an issue by themselves, not a cleaning company, the user could get a
small money reward for the completed work. The cleaning company could use
the timestamps of the issue for the accounting of the time from the report to
fixing.
People should be able to report issues through the app in an easy and intuitive
way. It is desirable for the app to ask the users different questions depending on
the issue. Another thing the system is good to support is a way for institutions to
self-suggest themselves as partners.

<img src="https://i.imgur.com/KXl4eCR.png" />

The users of the app are mainly going to be responsible citizens, who could
invest a minute of their time to report an issue.

1.1. Existing Technologies and Realisations

<img src="https://i.imgur.com/cfTC0H3.png" />

“Citizens” is the only existing realisation of this idea that was found. The CEO
of this application is from Bulgaria, who was talked to before the development
of the app was started. He gave practical guidelines for the possible goals of the
app to be made. This application supports most of the features that were present
in the functional requirements of the thesis work, such as issue submission,
filtering issues by location, by city, etc. During the realisation, however, there
are some features that are missing, such as voting for institutions. Moreover,
because the “Citizens” application is developed multiple times, once per
platform (Android and IOS), which requires a lot of maintenance. Another thing
that happens is that the user interface becomes clunky and inconsistent, because

every feature has to be translated to the native language for each and every
platform every time something new has to be added in the app. The application
developed during this thesis work upgrades a lot on top of the “Citizens” app in
the form of user interface and seamless viewing of existing issues because of the
automatic synchronisation that Firebase, which was chosen as a backend
service, provides.
Conclusion
There were lots of technologies, frameworks, languages and concepts that had
to be learned, used and understood for the realisation of this thesis work
application. A programming language was used for the thesis work itself - La
teX. Existing realisations of this idea were researched as well as design patterns
and was spoken to the CEO of the best realisation found - Стоян Митов,
regarding guidelines for the project development. The application as it was at
the beginning of development did not have much in common with what it is
now, but there had to be somewhere to start from. The front-end framework,
Flutter, is an amazing technology, despite it still fledgling and at the beginning
of its development. This thesis work tries to show that experimentation is a
good approach as long as it is well reasoned and the development experience is
good. Not only is the product of this thesis work relevant, but it is a realisation
of a very up-to-date idea - taking care of the environment and the infrastructure
around us. What this thesis work has achieved is significant, because it shows
how much can be achieved when there is a valid idea and a structured
development plan and how aesthetically pleasing it can look. In the future, the
developer should fix some minor issues and bugs in the app and the reader can
take a closer look at the technologies that were used in this work, because their
quality is top-notch and they are very likely to be used extensively in the future.
