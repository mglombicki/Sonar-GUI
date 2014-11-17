/*************************************************
    Sonar GUI
    By: Michael Glombicki (2013)
    (With serial code by Tom Igoe)

    The UI code expects serial data to be sent
    as a string in the format: angle,value
    For example, "120,2500" corresponds to an angle
    of 120 degrees and a range of 25 cm.
*************************************************/

import processing.serial.*;

int PORT_NUMBER = 0; // This will vary by USB port used
float MAX_RANGE = 35; // in centimeters
float OFFSET = PI / 2; // Used to make the radar top be 0 degrees
int POINT_COUNT = 100;

Serial myPort; // The serial port
int centerX;
int centerY;
int radius;
float[] xHits = new float[POINT_COUNT];
float[] yHits = new float[POINT_COUNT];
int counter = 0;


void setup()
{
    // set the window size:
    size(600, 500);
    centerX = width / 2;
    centerY = height / 2;
    radius = int(0.75 * min(width, height));

    // Uncomment this line below to list all the available serial ports
    // This is useful for finding out which port your device is on.
    println(Serial.list());

    // Access the serial port for the rangefinding device
    myPort = new Serial(this, Serial.list()[PORT_NUMBER], 9600);
    myPort.bufferUntil('\n'); // wait for a newline character

    // Set inital background color
    fill(0);
    strokeWeight(5);
}

void draw()
{
    // Instead of drawing every timestep, only draw when serial data is recieved
}

void serialEvent(Serial myPort)
{
    // Get the string message sent from the device:
    String reading = myPort.readStringUntil('\n');
    String[] parts = reading.split(",");
    float angle = float(parts[0]) / (180 / PI);
    float range = float(parts[1].replaceAll("(\\r|\\n)", "")) / 100; // converts to cm

    // Draw the radar screen
    background(200);
    fill(0);
    text(parts[0], width / 2 - 20, 30);
    stroke(255);
    ellipse(centerX, centerY, radius, radius);
    // Draw the radar line from the center to the data point
    stroke(0, 150, 0);
    float len = (radius / 2) * (range / MAX_RANGE);
    line(centerX, centerY, centerX + (len) * cos(angle - OFFSET), centerY + (len) * sin(angle - OFFSET));

    // Add the data points to the radar map
    xHits[counter % POINT_COUNT] = centerX + (len) * cos(angle - OFFSET);
    yHits[counter % POINT_COUNT] = centerY + (len) * sin(angle - OFFSET);
    counter++;
    noStroke();
    int intensity = 0; // Use a variable intensity value to show older points fading away
    for (int i = counter % POINT_COUNT; i < POINT_COUNT; i++)
    {
        fill(0, intensity, 0);
        ellipse(xHits[i], yHits[i], 3, 3);
        intensity += 2;
    }
    for (int i = 0; i < counter % POINT_COUNT; i++)
    {
        fill(0, intensity, 0);
        ellipse(xHits[i], yHits[i], 3, 3);
        intensity += 2;
    }

    // Draw the range bar background
    fill(0);
    text((range) + "cm", 30, 25);
    stroke(255);
    rect(30, 35, 20, radius);
    // Draw the current range value
    noStroke();
    fill(0, 150, 0);
    rect(31, radius + 35, 19, -range * (radius / MAX_RANGE));
}

