# Carbon Intensity Dashboard

Your task is to create the ‘Carbon Intensity Dashboard’, a mobile app which will present the live
carbon intensity and the carbon intensity for the current day, allowing the user to determine if now
is a good time to use energy.

You will be using the Carbon Intensity API (https://carbon-intensity.github.io/api-
definitions/#carbon-intensity-api-v2-0-0) to retrieve the relevant data - it is up to you to decide

which endpoints would be the best to use.
The main screen of the app should contain a widget which displays the current national carbon
intensity, and a graph showing the national half-hourly carbon intensity for the current day. This
data should be as up to date as is reasonably possible and presented in an easily understandable
way, handling any loading and error states.

## How it works

The code follows the Model–view–controller (MVC) software design.

The Model (carbon_intensity_model) handles data fetching from the given API and data processing.
The View (carbon_intensity_view) displays the UI components of the current carbon intensity and the
graph of today's carbon intensity. It is updated by the controller when the data changes.
The Controller (carbon_intensity_controller) handles the interaction between the model and the view,
requesting data from the model and updating the view.

The Model has two functions, fetchCurrentIntensity() and fetchDailyIntensityData().
The first one issues a HTTP get request for the API to receive the carbon intensity of the last half
hour. If the HTTP response has status 200, it decodes the received JSON data and returns the actual
intenstiy value. Otherwise, an exception is thrown.
The second one issues a HTTP get request for the API to receive the carbon intensity of the entire
day. If the HTTP response has status 200, it decodes and returns the received JSON data. Otherwise,
an exception is thrown.
It is possible to not get a response at all, e.g. the user does not have internet connection. The
get request then throws an error, and the app does not display any data. Note that this does not
crash the app, information will simply be not displayed.

The View contains three classes, CarbonIntensityGraph, Dashboard, and CurrentCarbonIntensity.
The Dashboard represents the entire page, and contains the title of "Carbon Intensity Dashboard", a 
widget of CurrentCarbonIntensity, and a widget for graph using CarbonIntensityGraph.
CurrentCarbonIntensity has a title, and the current intensity displayed if not null. Otherwise, the
text "Loading..." is displayed to indicate data fetching and missing data.
CarbonIntensityGraph plots a graph of actual and forecasted carbon intensity values. The graph is
interactive, meaning users can drag across the timeline to display exact intensity values for both
actual (green) and predicted (blue). Finally, a legend is displayed below the graph to explain the
colouring.

The Controller contains ValueNotifiers for current intensity, actual and forecasted values, and time
labels. When a value is replaced with something that is not equal to the old value, this notifies
its listeners. This ensures that old values are not deleted as data is re-fetched, avoiding a
"blinking" graph and page. The controller has a timer, set to fetch data every 5 minutes. I chose 5
minutes to avoid putting too much load on the server while still receiving new data. It is better to
use a periodic timer rather than asking for update at HH:00 and HH:30, which are the update times
the API promises. This is because if the server timer is slightly off, and the fetched data does not
contain new information yet, users would have to wait another 30 minutes to receive that data, even
though it might have been available for the last 29 minutes! Similarly, if there is an error on the
API, with false or non-existent data, users would go without an update for 30 minutes. Finally, if
the API is changed later to give information e.g. every HH:15 and HH:45, this implementation would
not follow it. Therefore, a periodic timer is implemented instead.
The controller's fetchData function fetched data of both current and daily carbon intensity. The 
data points are converted to FlSpot objects for the view to display, and the labels are formatted.
The data is cropped to show only until the current time, as the purpose of the application is to
indicate whether it is a good time to use energy, and not to show future predictions of the day.

Finally, the main initialises the model and controller, fetches the data, starts the timer, and
starts the application.

## Future improvements
In the future, the application's aesthetics can be improved.
Currently, some of the labels are overlapping or start on a new line mid-way, to maximise the space
available for the graph. Finding a better balance between graph area and label clarity is possible.
When data is fetched, the index of low, medium, and high usage of energy is included. This
information could be used to change the colour of the current carbon intensity widget and help users
by indicating if it is a good time to use energy based on the API's recommendation. It could also
return written advice in text.
Finally, some test cases by creating dummy data could check if the display of the app indeed works
correctly, or that all error types are handled appropriately.


