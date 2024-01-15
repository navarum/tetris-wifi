# tetris-wifi

Console Tetris wrapper, instrumented to measure biological effects of 802.11 RF "WiFi" radiation using randomized, blinded, self-experiments. Performs a properly randomized version of an experiment carried out by Svante Arrhenius in 1911, and possibly repeated by Nikola Tesla in 1913.

Before the start of each game, the script randomly decides whether to emit WiFi radiation during the game (but without revealing this decision to the user). At end of each game, the script asks the user several questions and records the answers, as well as what the WiFi status was, and data about game score and other game statistics, in a log file which can be analyzed later.

## Installation:

- Install Zsh, if you haven't already.

- Edit and test `wifi-flood-daemon` to make sure that it does the right thing on your laptop. Ideally you should be able to detect a change using an RF meter. Also, it should restore the network when it is done.
    
        $ ./wifi-flood start
        $ ./wifi-flood stop
        Killing process
        Sent signal

- Run something like `make PREFIX=~/.local install`.

- Install my [instrumented version of bsdgames tetris](https://github.com/navarum/tweaks/blob/master/tetris/CHANGES.md). This version collects data that will end up in `~/.tetris-wifi`.

        git clone https://github.com/navarum/tweaks tweaks.navarum
        ./tweaks.navarum/examples/install-tweaks tetris

- Test with a meter and `tetris-wifi -t`.

        $ tetris-wifi -t
        Testing wifi-flood (pulse)
        Testing wifi-flood (off)
        Killing process
        Sent signal

- Run `tetris-wifi` every time you want to play Tetris. Unrecognized arguments are passed to the `tetris` command, so for example you can specify the keybindings:

        $ tetris-wifi -k 'jkl pq'

  Before you start collecting data, open an issue on GitHub to let me know that you are planning to replicate this experiment. This helps prevent reporting bias.

- Try to reduce the variance by always playing under similar conditions.

- Figure out a good way to analyze the resulting data. Some R code that I used for this is in [tdata.R](tdata.R), and log files from my own self-experiment are in [data-2020-04-09](data-2020-04-09). If you are interested in doing your own experiments, then it might be better to avoid looking at my analysis code and log files before you start.

## Results

After running the experiment for 100 games, I found no results of significance, except possibly that when restricting the analysis to the first 53 games there was a significant trend (p=0.96) in which my game scores were correlated with the radio status. Because I also tested for a number of other correlations, the p-value should not be considered significant unless one could argue that I should have looked for this one first. However, the midway point of the experiment was approximately the point in time at which my scores stopped increasing, or in other words I was done "getting better" at Tetris, so it is possible to imagine that the WiFi only affected my scores during this first phase for some reason. It would be interesting to try the experiment with more people, now that I have an idea of what correlations to test for. Given the prevalence of WiFi and cellular phone radiation in modern cities, it may be difficult to find test subjects whose daily exposure isn't high enough to dwarf the effects of laptop WiFi radiation. I was living near a 5G cellular antenna when I did this experiment on myself, but I didn't go outside much due to the lockdown, and the signal amplitude was much lower inside my apartment. I found it helpful to purchase an RF meter to measure my laptop output and the baseline in my surroundings.

I used a [Trifield EMF meter](https://www.trifield.com/product/trifield-emf-meter/) to measure the radiation levels around my house, and to try to figure out the best way to get my laptop to emit radio waves. I found that simply initiating a scan for access points (`iwlist wi0 scan`) was sufficient to produce a large spike in the radiation intensity (perhaps because scanning requires the radio to emit pulses at maximum amplitude). So I just wrote [wifi-flood-daemon](wifi-flood-daemon) (the program used to produce radio waves in this project) to do a scan in an infinite loop. However, it may be that there is a better way to make the wireless device emit lots of radiation.

## Further reading:

I have added some papers to the repository that may be of interest.

- [Gilliams, 1913, "Teslas Plan of Electrically Treating School Children"](papers/gilliams.pdf). Digitized by Google from the magazine "Popular Electricity". Article describes a planned experiment by Nikola Tesla to determine the effect of radio waves on the development of "mentally defective" school children in New York. I could find no record of the results of the planned experiment. The article also refers to an earlier experiment performed in 1911 by physical chemist and climate science pioneer Svante Arrhenius, which involved exposing schoolchildren in Stockholm to radio waves ([more information here](https://spark.iop.org/sensational-electric-learning)). The "Stockholm experiment" of Arrhenius reported health benefits from radio wave exposure. Some of this information is difficult to find online without very specific search terms.

- [Wyde et al, 2016, "Report of Partial Findings from the National Toxicology Program Carcinogenesis Studies of Cell Phone Radiofrequency Radiation"](papers/wyde.pdf). This paper describes what I think is the most careful and comprehensive published experiment involving cellular-frequency radio waves and lab animals. The experiment found that radio waves cause cancer, but that they also cause the experimental animals to live longer. The second part of the findings was not reported in media coverage of the experiment, which was itself very limited.

I was motivated mostly by curiosity to write this code and to experiment on myself. It is clear from published sources like the above that radio waves have a definite biological effect, but there is surprisingly little public interest in what that effect is. This is despite the fact that in modern times it would be easy to (secretly or not) do experiments on large numbers of people in order to form solid conclusions about specific effects of radio waves - with much less effort than must have been exerted by Tesla and Arrhenius. Simple experiments could be devised by school principals or the makers of mobile-phone based video games to measure the effect of small changes in radiation exposure on large groups. For example, a mobile game designer could try randomly changing the amount of data that is sent in the background over the phone antenna, and recording any associated changes in game play statistics for each user. A school principal could randomize the placement of WiFi access points used by multiple classrooms, and track student progress after a year.

Although I am not in a position to perform large-scale experiments like these, I nevertheless had to admit that there was nothing stopping me from experimenting on myself. The results of my self-experimentation were somewhat inconclusive, but if what I found was not spurious, then my results were consistent with the strange findings of earlier studies.
