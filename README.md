# endofsemproject

#Description
This project is about built  abstractions in scheme that can be used by developers to build software systems that analyze the moods of Tweets for a given country e.g Uganda



#installation
If you don't have Racket installed, Download and install Racket from https://racket- lang.org/download/

#dependencies
1. Download the data science abstractions from https://github.com/n3mo/data-science
2. Extract the data science abstractions zip folder into the Racket v6.11/collects folder.
This will add a new folder named “data-science-master”
3. The data science abstractions may require other packages. To install any additional
package download and unzip the file into /collects/ folder
a. csv-reading https://pkgs.racket-lang.org/package/csv-reading
b. mcfly https://pkgs.racket-lang.org/package/mcfly
c. overeasy https://pkgs.racket-lang.org/package/overeasy

e.g 
#lang racket
(require data-science-master)
(require plot)
(require json)
(require math)
(require racket/date)
 ;;; end of code snippet

#run

After pulling all the dependencies  together, run the Allan-Murungi-2.rkt file.
