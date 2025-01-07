#import "lib.typ": typs
#set text(lang: "it") 
#set enum(indent: 1.8em)
#set list(indent: 1.8em)

#show: typs.with( 
  title: text(25pt)[Progetto di Social Computing
  #show raw.where(block: false): set text(size: 12pt)
  #show raw: set text(font: "Roboto Mono")
    #text(15pt)[\ Analisi delle dipendenze del pacchetto _#raw("@angular/cli")_ di `npm`]
  ],
  author: "Jacopo Danielis [162553], Massimiliano Di Marco [144714],\nAurora Marzinotto [162556], Enrico Peressin [163503]",
  date: datetime(year: 2025, month: 1, day: 7),
  abstract: [
    Corso di Social Computing, \ a.a. 2024/2025 
  ],
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),

  
)



= Introduzione 

== Sommario
L'obiettivo di questo progetto è sviluppare un software in grado di generare e analizzare il *grafo delle dipendenze* di un qualsiasi pacchetto #raw("npm"), visualizzandolo graficamente e calcolandone alcuni parametri. 
\
In un grafo delle dipendenze, ogni nodo rappresenta una libreria o un pacchetto software, mentre ogni arco (diretto) indica una relazione di dipendenza. Si ottiene così una *rete* che evidenzia i componenti che dipendono da altri per funzionare correttamente.
\
Nella seconda fase del progetto, il grafo verrà trasformato in indiretto, con l'aggiunta di nodi e archi artificiali, per calcolare metriche sui grafi risultanti. Verranno così confrontate le misure per dedurre delle proprietà afferenti ai grafi creati.


== Descrizione generale del lavoro  
Le funzionalità che il software deve rispettare sono riportate di seguito: 
  + Costruzione del grafo delle dipendenze del _seed_ tramite `requests`e `NetworkX`.
  + Trasformazione del grafo in indiretto con aumento di nodi e archi secondo la tecnica del _preferential attachment_.
  + Come bonus l'uso di una variante del _prefential attachment_: il _random walk_.
  + Visualizzazione statica con layout di Fruchterman-Reingold dei grafi. 
  + Visualizzazione interattiva con `PyVis` dei grafi. 
  + Calcolo di varie metriche sui grafi.

= Metodologia

== Strumenti Utilizzati 
 Librerie Python 
  - #raw("requests"): Per interagire con l'API ufficiale di `npm` e raccogliere i dati delle dipendenze in formato JSON.
  - #raw("NetworkX"): Per costruire e analizzare i grafi, calcolando le rispettive metriche.
  - #raw("PyVis"): Per visualizzare i grafi in modo interattivo.
  - #raw("Matplotlib"): Per creare le visualizzazioni statiche dei grafi.
  - #raw("numpy"): Per effettuare calcoli e manipolare i dati.

  

== Costruzione dei grafi

=== Grafo diretto
Utilizzando l'algoritmo di visita *BFS* è stato costruito il grafo diretto aciclico (DAG) delle dipendenze in cui i nodi rappresentano i pacchetti e gli archi le relazioni di dipendenza (fino al livello più profondo).
Il grafo è stato poi serializzato in formato JSON: `data/grafo_diretto.json`.


=== Grafo indiretto con _preferential attachment_
Successivamente si è costruito un grafo indiretto a partire dal grafo diretto. Esso è stato aumentato utilizzando la tecnica del _preferential attachment_, ovvero aggiungendo nodi artificiali che vengono collegati ai nodi già presenti secondo una probabilità $p$ proporzionale al grado dei secondi. È stato scelto di inserire $400$ nodi artificiali con un valore di archi $m$ per nodo pari a $3$ per un totale di $1200$ archi.
Il grafo risultante è stato poi serializzato in formato JSON: `graphs/grafo_artificiale.json`


==== Grafo indiretto con _random walk_
Con lo stesso numero di nodi (400) e di archi (3) è stata usata la variante del preferential attachment detta _random walk_. Per ogni nodo aggiunto, il primo arco viene connesso a un nodo $K$ scelto uniformemente tra quelli già presenti nel grafo. Per i restanti $m-1$ archi ogni arco viene connesso con probabilità $p = 0.8$ a uno dei vicini del nodo scelto $K$ (nota se non esiste un vicino disponibile è stato scelto di "perdere" l'arco). 
In caso contrario, viene scelto un altro nodo uniformemente tra quelli già nel grafo.
Il valore di $p = 0.8$ è stato scelto per mantenere un equilibrio tra la località delle connessioni e la casualità.
Il grafo risultante è stato poi serializzato in formato JSON: `graphs/grafo_artificiale_v2.json`



= Visualizzazione dei grafi 

== Statica 
Sia per il grafo diretto che per quelli indiretti è stata prodotta una visualizzazione statica utilizzando il layout di Fruchterman-Reingold. Per fare ciò è stata inizialmente creata una figura per la visualizzazione, per poi calcolare le posizioni dei nodi utilizzando il layout Spring e disegnare il grafo sulla figura creata.  
Le immagini ottenute sono state salvate in #raw("grafici2d/grafico_diretto.png"), #raw("grafici2d/grafico_artificiale.png") e `grafici2d/grafico_artificiale_v2.png`


==  Interattiva
Dopo aver calcolato i quartili della distribuzione dei gradi, è stata prodotta una visualizzazione interattiva dei grafi utilizzando la libreria #raw("PyVis"). 

La dimensione di ciascun nodo è proporzionale al numero dei propri archi in uscita (nei grafi artificiali indiretti _out-degree_ = _degree_) e il colore è stato assegnato secondo i seguenti criteri: 
- *Grigio*: nodi appartenenti al primo quartile della della distribuzione dei grafi, quindi i nodi con grado minore;
- *Blu*: nodi del secondo quartile;
- *Viola*: nodi del terzo quartile;
- *Giallo*: nodi del quarto quartile;
I grafi prodotti sono stati salvati in formato HTML nei file `html/grafo1_interattivo.html` e `html/grafo2_interattivo.html`. 

 

= Calcolo delle metriche

== Grafo diretto
Partendo dal presupposto che il grafo in analisi sia un _DAG_, è noto che esso non sia fortemente connesso. Tuttavia, tale proprietà è stata verificata utilizzando la funzione #raw("nx.is_strongly_connected()").

A seguito di questa verifica, si è concluso che le misure di centralità globali, come il centro e il raggio, non risultano calcolabili, in quanto richiedono la forte connettività.

Per quanto riguarda la distanza media e la distanza massima, è stato possibile superare il limite imposto dalla non forte connettività calcolando le distanze per ciascun nodo singolarmente e aggregando successivamente i risultati.

Il clustering medio è stato determinato attraverso l'utilizzo della funzione #raw("nx.average_clustering()"), che considera il grafo come indiretto, al fine di garantire coerenza con i grafi artificiali indiretti.

Infine, le metriche _sigma_ e _omega_ non sono supportate da #raw("NetworkX") per i grafi diretti e, di conseguenza, non è stato possibile calcolarle. Tutte le misure ottenute sono state salvate nel file #raw("misure/misure_grafo_diretto.json").


== Grafi indiretti
Per i due grafi artificiali non diretti, sono state calcolate tutte le misure richieste, ad eccezione del _PageRank_, che non è stato incluso in quanto non significativo per questa tipologia di grafo.

È importante notare che le misure di _in-degree_ e _out-degree_ sono state equiparate al _degree_, essendo equivalenti in un grafo indiretto.

Per quanto riguarda il calcolo di _sigma_ e _omega_, i parametri `niter` e `nrand` della funzione di `nx` sono stati ridotti rispettivamente a 5 e 10. Questa scelta è stata effettuata per ridurre i tempi di esecuzione, mantenendo comunque un’accuratezza accettabile per entrambe le misure.


= Conclusioni
== Visualizzazione statica
=== Grafo diretto
Nella visualizzazione ottenuta con lo _spring layout_, i nodi assumono una posizione basata su forze attrattive e repulsive, proporzionali al numero di connessioni. Osserviamo che un _gruppo di nodi centrali_ costituisce il "cuore" del grafo, caratterizzato da un alto numero di connessioni: pacchetti altamente dipendenti da altri e pacchetti che fungono da referenti per molti altri, o entrambe le cose. Un numero significativo di _nodi periferici_ si dispone lungo la circonferenza. Questi rappresentano pacchetti "base", che non dipendono da altri (grado uscente basso o nullo) e che, allo stesso tempo, hanno pochi pacchetti che dipendono da loro (grado entrante basso).

Questa struttura evidenzia un nucleo complesso di pacchetti fortemente connessi e una periferia composta da librerie semplici e meno integrate nella rete.

=== Grafo indiretto con _preferential attachment_
Nel grafo indiretto generato tramite il modello di _preferential attachment_ osserviamo una distribuzione spaziale più "distesa" ma al centro il numero di archi è molto più denso indicando che ci sono dei nodi centrali con un grado molto alto, detti _hub_, che hanno un alto numero di connessioni, coerentemente con il modello del _preferential attachment_, che privilegia i nodi con grado elevato nelle nuove connessioni. I nodi periferici sono distribuiti attorno alla circonferenza e hanno pochi collegamenti, spesso limitati agli hub centrali. Questo sembra suggerire che viene rispettata la distribuzione _power law_ attesa che viene confermata anche dal grafico della distribuzione cumulativa dei gradi presente in `grafici2d/power_law.png`

=== Grafo indiretto con _random walk_
Nel grafo indiretto ottenuto con _random walk_ osserviamo, a parità di costante $k$ di _spring_, una densità meno alta di archi al centro, ma sopratutto più cluster di nodi e archi tra i nodi periferici. Viene mantenuta comunque una zona centrale con i nodi con più connessioni, gli _hub_, e difatti anche questo grafo conferma oltre che qualitativamente anche nel grafico in `grafici2d/power_law_v2.png` che viene seguita una distribuzione _power law_ dei gradi dei nodi.

== Visualizzazione Interattiva
La visualizzazione dinamica permette di muovere i nodi, offrendo un'analisi interattiva delle reti. Selezionando un nodo i suoi collegamenti verranno evidenziati, permettendo di visualizzare chiaramente le sue dipendenze. 


=== Grafo diretto

Nel grafo diretto notiamo alcuni nodi particolarmente prominenti, come `angular-cli` con grado uscente di 67, indicato dalla sua grande dimensione e colorazione distintiva. Tuttavia, questi nodi sono pochi e si osserva una rapida decrescita nelle dimensioni, con un gran numero di nodi piccoli posizionati lungo la periferia. Questa struttura evidenzia la centralità di pochi pacchetti chiave e la semplicità relativa dei pacchetti periferici, che hanno poche dipendenze o connessioni.

=== Grafo indiretto con _preferential attachment_

Nel grafo indiretto generato con il modello del _Preferential Attachment_, emerge chiaramente la presenza di nodi centrali molto grandi, i cosiddetti _hub_, che hanno un numero estremamente alto di connessioni. Questo risultato è coerente con il meccanismo del modello, che privilegia i nodi con grado maggiore, rafforzando la loro centralità nella rete.
Rispetto al grafo diretto, osserviamo un aumento significativo del numero di archi. Inoltre, si nota una maggiore granularità nella dimensione dei nodi: i nodi più piccoli mantengono dimensioni diverse, rappresentando pacchetti con connettività intermedia. Tuttavia, i nodi gialli più grandi sono chiaramente più prominenti rispetto agli altri grafi, indicando la forte influenza del grado nel processo di connessione.


=== Grafo indiretto con _random walk_

Nel grafo indiretto generato con il modello del _Random Walk_, la struttura generale si presenta meno centralizzata rispetto al _Preferential Attachment_. Sebbene si osservino ancora _hub_ centrali con un alto numero di connessioni, la loro dimensione è leggermente inferiore rispetto al modello precedente, a causa dell'introduzione di maggiore casualità nel processo di collegamento. Inoltre è ben visibile la presenza di archi tra i nodi periferici a suggerire una maggiore clusterizzazione del grafo.
La granularità nella dimensione dei nodi è evidente anche qui, con una distribuzione equilibrata che riflette una gerarchia meno rigida.


== Calcolo delle metriche

L'analisi delle metriche sui tre grafi rivela differenze significative nella loro struttura, evidenziando le caratteristiche uniche del grafo diretto e dei due grafi indiretti (_Preferential Attachment_ e _Random Walk_).

=== Grafo diretto

Il grafo diretto, essendo un DAG, presenta alcune limitazioni strutturali ma anche caratteristiche distintive. La distanza media è pari a $2.122$, la più bassa tra i tre grafi, che riflette una struttura compatta e gerarchica. La distanza massima, invece, è pari a $8$, indicando una profondità moderata della rete. Il clustering coefficient, pari a $0.0905$, è basso ma non trascurabile, evidenziando una scarsa formazione di triadi. La transitivity, pari a $0.0258$, conferma un clustering globale molto basso. Questi risultati mostrano come il grafo diretto tenda a una struttura gerarchica con un clustering limitato.

=== Grafo indiretto con _preferential attachment_

Il grafo indiretto generato con il modello di _Preferential Attachment_ mostra una struttura più espansa rispetto al diretto. La distanza media è pari a $4.218$, mentre la massima raggiunge $10$, evidenziando una rete più ampia e ramificata. Il clustering coefficient è di $0.0705$, leggermente inferiore al diretto, segnalando una perdita di clustering nella transizione, mentre la transitivity, pari a $0.0423$, suggerisce un leggero aumento di connessioni locali.
Il valore di _sigma_, pari a $2.307$, conferma che il grafo possiede proprietà "small-world". _Omega_, invece, con un valore di $-0.019$, si avvicina a zero, rappresentando un equilibrio tra struttura randomica e organizzata. Valori inferiori a zero indicano reti più reticolari, mentre valori maggiori segnalano reti casuali.
Questi risultati evidenziano come il modello di _Preferential Attachment_ bilanci una struttura distribuita con proprietà di rete "small-world".

=== Grafo indiretto con _random walk_

Il grafo indiretto generato con il modello di _Random Walk_ evidenzia una struttura più decentralizzata e clusterizzata rispetto al _Preferential Attachment_. La distanza media è pari a $4.919$, la più alta tra i tre grafi, riflettendo una struttura meno centralizzata. La distanza massima conferma ciò ed è pari a 12, superiore a quella del _Preferential Attachment_. Il clustering coefficient raggiunge un valore di $0.425$, significativamente più alto rispetto agli altri grafi, evidenziando una forte propensione alla formazione di cluster locali. La transitivity è pari a $0.159$, la più alta tra i tre grafi, coerente con l'aumento del clustering. Il valore di _sigma_, pari a $11.703$, riflette una rete estremamente "small-world", mentre _omega_, con un valore di $-0.144$, indica una rete più decentralizzata rispetto al _Preferential Attachment_, con caratteristiche che tendono maggiormente a un reticolo. Questi risultati mostrano come il modello di _Random Walk_ favorisca una struttura più clusterizzata, decentralizzata e *small world*, incrementando significativamente il clustering e la transitivity, ma aumentando anche la distanza media.

=== Osservazioni conclusive

Il modello di _Preferential Attachment_ sacrifica parte del clustering del grafo diretto, con una perdita di $0.02$ nel clustering coefficient rispetto al diretto, in favore di una struttura più espansa e di un equilibrio "small-world" quasi ottimale, come indicato da _omega_ vicino a $-0.01 9$. Il modello di _Random Walk_, invece, aumenta notevolmente il clustering, con un incremento di $0.3345$ rispetto al diretto, e la transitivity, favorendo la formazione di cluster locali. Questo si riflette anche in un _sigma_ più elevato rispetto al _Preferential Attachment_, ma a costo di una distanza media più alta e di un _omega_ più negativo. Entrambi i grafi indiretti mostrano distribuzioni _power law_, evidenziando la presenza di hub centrali con gradi elevati, coerenti con i rispettivi modelli generativi.