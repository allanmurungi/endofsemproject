#lang racket

;;; For this project,we will use,
;;; - data-science to process the text,
;;; - plot to visualize the results
;;; - json to parse the data 


(require data-science-master)
(require plot)
(require json)
(require math)
(require racket/date)



;;;This function reads line-oriented JSON which is the output
;;;from massmine when retrieval of tweets is successfull
;;; and packages it into an array
(define (json-lines->json-array #:head [head #f])
  (let loop ([num 0]
             [json-array '()]
             [record (read-json (current-input-port))])
    (if (or (eof-object? record)
            (and head (>= num head)))
        (jsexpr->string json-array)
        (loop (add1 num) (cons record json-array)
              (read-json (current-input-port))))))

;;; Read tweets from json file where the 500 tweets from Uganda are stored.
(define our_tweets (string->jsexpr
                (with-input-from-file "uganda_tweets.json" (λ () (json-lines->json-array)))))

;;; We need  just the some data from the tweet information so we filter out just the tweet text,source and timestamp from each tweet
;;; hash.Retweets are removed.
;;; This function removes just the tweet text, source, and timestamp from each tweet hash and athen removes retweets.
(define cleaned_tweets
  (let ([tmp (map (λ (x) (list (hash-ref x 'text) (hash-ref x 'source)
                               (hash-ref x 'created_at))) our_tweets)])
    (filter (λ (x) (not (string-prefix? (first x) "RT"))) tmp)))




;;; Now we clean up each tweet using the abstractions "string-normalize-spaces","remove-urls", "remove-punctuation" and "string-downcase"
;;;imported from racket and data-science-master.
;;; We remove URLs , punctuations ,case and spaces from each tweet.
;;; This function takes a words and returns a
;;; preprocessed word.
(define (preprocess-our-tweet str)
  (string-normalize-spaces
   (remove-punctuation
    (remove-urls
     (string-downcase str)) #:websafe? #t)))


;In this abstraction, we normalize our tweets and clean them up by getting  just the tweet text,source and timestamp from each tweet.
(define preprocessed-cleaned-tweets (map (λ (x)
                 (remove-stopwords x))
               (map (λ (y)
                      (string-split (preprocess-our-tweet y)))
                    ($ cleaned_tweets 0))))


;;; Here we define/generate a list of words by removing empty strings from the given tweets and we also flatten the given tweets(normalized and cleaned).
(define word-list (filter (λ (x) (not (equal? x ""))) (flatten preprocessed-cleaned-tweets)))


;;; Here, we sort the text from the tweets given and generate a word list.
;;; We use the "sort" abstraction from racket and the "sorted-counts" abstraction from data-science-master
(define sorted-text (sort (sorted-counts word-list)
                     (λ (x y) (> (second x) (second y)))))

;;; Now to begin our sentiment analysis, we extract each unique word
;;; and the number of times it occurred (Frequency) by providing the word list to the "document->tokens" abstraction
;;; from data-science-master
;;(define our-words (document->tokens sorted-text #:sort? #t))

(define our-words sorted-text)


;;; Plotting the top 40 words against their occurences
(parameterize ([plot-width 600]
               [plot-height 600])
    (plot (list
        (tick-grid)
        (discrete-histogram (reverse (take our-words 1000))
                            #:invert? #t
                            #:color "LightSeaGreen"
                            #:line-color "LightSeaGreen"
                            #:y-max 450))
       #:x-label "Occurrences"
       #:y-label "word"))


;;; We use the "list->sentiment" to label each (non stop-word) with an
;;; emotional label by using nrc lexicon. 
(define our-sentiment (list->sentiment our-words #:lexicon 'nrc))


(take our-sentiment 50)
;;; --> '(("word" "sentiment" "freq")
;;;       ("love" "anticipation" 367)


;;; The sentiment, created above, consists of a list of triplets of the pattern
;;; (token sentiment freq) for each token in the document. Many words will have 
;;; the same sentiment label, so we aggregrate (by summing) across such tokens.
(aggregate sum ($ our-sentiment 'sentiment) ($ our-sentiment 'freq))
;;; --> '(("anticipation" 4739)
;;;       ("positive" 9206)
;;;       ("joy" 3196)
;;;       ("trust" 5095)
;;;       ("surprise" 2157)
;;;       ("negative" 7090)
;;;       ("fear" 4136)
;;;       ("sadness" 3317)
;;;       ("anger" 2765)
;;;       ("disgust" 1958))

;;; Now we  visualize all the results as a barplot (discrete-histogram)
(let ([counts (aggregate sum ($ our-sentiment 'sentiment) ($ our-sentiment 'freq))])
  (parameterize ((plot-width 800))
    (plot (list
	   (tick-grid)
	   (discrete-histogram
	    (sort counts (λ (x y) (> (second x) (second y))))
	    #:color "LightSeaGreen"
	    #:line-color "OrangeRed"))
	  #:x-label "Sentiment"
	  #:y-label "Frequency")))


