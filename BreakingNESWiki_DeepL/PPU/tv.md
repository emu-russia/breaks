## NTSC Video

The video signal layout is as follows:

![ntsc](/BreakingNESWiki/imgstore/ntsc.png)

- This picture shows a single line layout
- First there is the horizontal sync pulse (HSYNC), so that the beam is set to the beginning of the line
- After the HSYNC pulse is the "back porch" which contains a special "flash": 8-10 subcarrier pulses, for the phase locked loop (PLL). 
- Then comes the image signal itself
- The signal of the line ends with the so called "front porch"

Now for some clarification.

First - the NTSC standard was created with compatibility with black and white television in mind. In the B&W signal, you could only set the brightness of the signal, which simply changed depending on the amplitude. Back porch and front porch were black borders on the left and right sides of the screen.

To add a color component, the developers added phase modulation:

<img src="/BreakingNESWiki/imgstore/ntsc_color.gif" width="700px">

At the same time, the average amplitude again remained brightness, and the phase shift within the phase "package" and the amplitude began to represent chromaticity. At the same time black and white TV sets did not perceive the phase component and worked only by the averaged amplitude.

To tell the decoder where the 0<sup>o</sup> is, a special "color burst" was added. The phase shift is counted relative to the oscillation of this burst.

The color component consists of two components: Saturation and Hue. Saturation is determined by the amplitude of the phase component, and Hue by the phase shift.

## Framing

Now let's talk about how one image frame is formed.

We must take into account the fact that the decomposition of a video signal into a line of pixels does not oblige the TV set to have a fixed number of pixels. A TV set has no pixels at all in the conventional sense. It has "grains." A signal can be "smeared" as much as 100 grains wide or as much as 1,000. This is a feature of the cathode ray tube.

The surface of a kinescope of old color TVs looks like this:

<img src="/BreakingNESWiki/imgstore/crt_screen_closeup.jpg" width="500px">

The saturation and hue encoded in the color component of the subcarrier sets the brightness of the three electron beams: red, blue, and green. The rays fall on the grains, which are coated with a phosphor. The phosphor has an afterglow: after the beam has passed over the grain, it continues to glow for some time (usually fading after a few scanlines).

In contrast to the width, the number of lines of 1 full frame is clearly fixed by the NTSC standard and is 525 lines. Of these 525 lines, about 480 lines are dedicated directly to the image, and the rest are used for vertical synchronization (VSync).

"Approximately 480" because different TV models may actually output less, due to the tube design and construction of the TV. In doing so, some of the image may be hidden behind the edge of the screen.

## Other Features

The frame is output in two halves, using interlace method. The odd lines 1, 3, 5 etc. are output first, and then the even lines 0, 2, 4 etc. But in general it does not matter in what order to start the output, when forming an image it does not matter. When you turn the TV on, the beam starts scanning the screen (remember the "germ war"?) and the framing can start anywhere on the screen, after the receiver receives an adequate video signal.

The NTSC line frequency is 15734 Hz, and the frame frequency (or rather, half-frame frequency) is 59.94 Hz. This was done to reduce interference from subcarrier and audio. But the interference has not disappeared completely and appears in the form of "waves".
