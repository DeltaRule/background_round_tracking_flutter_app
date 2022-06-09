# Background Flutter Round-Tracking App

This is a simple Flutter App, which tracks ran rounds by the user. It also can be executed in the Background.<br>
The App uses the Flutter Location package and is created with the help of this Tutorial https://www.kindacode.com/article/how-to-get-user-current-location-in-flutter/ (10.06.2022).

## functionality

When the user starts the Programm the initial latitude and longitude are saved. If the user then leaves and 40m radius of the initial value a boolean gets reverted, so we know the user left the outer ring. If the user then enters a 20m radius, the Roundcounter is incremented.

## extra features

After Running rounds and stoping the execution, the user gets and graph displaying the time spend on the x axis and the rounds on the y axis.

## Ideas

For anyone looking into the app here are some improvements that can be made

- Fix the timer, so the timer gets updated within each second
- Find out how to modify the location Banner
- Make the App pretty
- Put setting on the app
- Design the Graph properly
