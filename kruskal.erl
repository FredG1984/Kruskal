-module(kruskal).
-export([kruskal/1]).

% cd("C:/Users/fred/Desktop/Erlang Übung").
% cd("D:/Sicherheit/Kruskal").
% cd("F:/Erlang Übung").   
% cd("Z:/GKA Vorbereitung").      

% c(kruskal).
% c(kruskal,[debug_info]).
% debugger:start().

% kruskal:kruskal(graph_11).                                                                                                                                                                                     
% kruskal:kruskal(adtgraph:getVertices(adtgraph:importG(graph_11,ud))).

%kruskal(Filename) -> adtgraph:importG(Filename,d).

kruskal(Filename) ->
IsTypeOf = util:type_is(Filename),
if
 IsTypeOf == atom -> findmincost(adtgraph:importG(Filename,ud));
 true -> []                                                                                                                    
end.

%-------------------------------------------------------------------------------------------------------------------------------
% findet Ecke mit den geringsten Kosten
%-------------------------------------------------------------------------------------------------------------------------------

findmincost(Adtgraph)-> findmincost(Adtgraph,adtgraph:getEdges(Adtgraph),adtgraph:getVertices(Adtgraph),adtgraph:setAtV(Adtgraph,0,minimalger,[]),0,0,0,0,0,0,0,0).                                                                                                                                                        %Sucht die Kannte                                                                                           
findmincost(AG,[],_Ed,_Kantenliste,Eck1,Eck2,_Eck1Comp,_Eck2Comp,_Weight,_WeightComp,_Flag,KantenAnzahl) -> start_eck(adtgraph:setAtV(AG,0,kantenanzahl,KantenAnzahl),Eck1,Eck2);                                                                             
findmincost(AG,[E1,E2|T],Ed,K,Eck1,Eck2,E1Cp,E2Cp,W,WC,F,KAnz) ->    
MARKED = adtgraph:getValE(AG,E1,E2,marked),                                                         										% prüfft ob Ecken schon markiert wurden                                                                                                                                                              
if
	MARKED == nil, WC == 0, T == [] -> findmincost(AG,[E1,E2|T],Ed,K,Eck1,Eck2,E1,E2,W,adtgraph:getValE(AG,E1,E2,weight),F,KAnz);
    MARKED == nil, F == 0 -> findmincost(AG,T,Ed,K,E1,E2,E1Cp,E2Cp,adtgraph:getValE(AG,E1,E2,weight),WC,F+1,KAnz); 							% W ist der Wert der immer fest gehalten
    MARKED == nil, WC == 0 -> findmincost(AG,[E1,E2|T],Ed,K,Eck1,Eck2,E1,E2,W,adtgraph:getValE(AG,E1,E2,weight),F,KAnz);							% WC steht für Weight Compare ist der Wert der varriert und mit W verglichen wird   ... kleiner Denkfeher mit T hätte tail nicht aufrufen sollen
    MARKED == nil, W > WC -> findmincost(AG,T,Ed,K,E1Cp,E2Cp,E1Cp,E2Cp,WC,0,F,KAnz);                                								% Dreieckstausch
	MARKED == nil, W =< WC -> findmincost(AG,T,Ed,K,Eck1,Eck2,E1Cp,E2Cp,W,0,F,KAnz);	
	true -> findmincost(AG,T,Ed,K,Eck1,Eck2,E1Cp,E2Cp,W,WC,F,KAnz+1)													  					% Sucht nach weiteren Wert                            
end.

%-------------------------------------------------------------------------------------------------------------------------------
% Sucht die Startecke dessen ausgehenden Kanten zusammen addiert die geringsten Kosten ergeben
%-------------------------------------------------------------------------------------------------------------------------------

start_eck(Adtgraph,Eck1,Eck2) -> start_eck(Adtgraph,Eck1,Eck2,adtgraph:getIncident(Adtgraph,Eck1),0,0,0,0).
start_eck(AG,Eck1,Eck2,[],_ACC,_Erg1,_Erg2,Check) ->  proof_mark(AG,Eck1,Eck2,Check);
start_eck(AG,Eck1,Eck2,[E1,E2|T],A,Erg1,Erg2,C) ->
if
  C == 2, Erg1 =< Erg2 -> start_eck(AG,Eck1,Eck2,T,0,Erg1,Erg2,C);
  C == 2, Erg1 > Erg2 -> start_eck(AG,Eck1,Eck2,T,0,Erg2,Erg1,C);
  C == 0, T == [] , Erg1 /= 0 -> start_eck(AG,Eck1,Eck2,adtgraph:getIncident(AG,Eck2),0,A,0,C+1);
  C == 0, T == [] , Erg1 == 0 -> start_eck(AG,Eck1,Eck2,[E1,E2|T],adtgraph:getValE(AG,E1,E2,weight)+A,A,0,C);
  C == 1, T == [] , Erg2 /= 0 -> start_eck(AG,Eck1,Eck2,[E1,E2|T],0,Erg1,A,C+1);                                                                                                                                                    %Reinfolge missachtet!!!
  C == 1, T == [] , Erg2 == 0 -> start_eck(AG,Eck1,Eck2,[E1,E2|T],adtgraph:getValE(AG,E1,E2,weight)+A,Erg1,A,C);
  A == 0 -> start_eck(AG,Eck1,Eck2,T,adtgraph:getValE(AG,E1,E2,weight)+A,Erg1,Erg2,C);    
  true -> start_eck(AG,Eck1,Eck2,T,adtgraph:getValE(AG,E1,E2,weight)+A,Erg1,Erg2,C)
end.

%-------------------------------------------------------------------------------------------------------------------------------
% Prüf ob die Sartecke schon markiert wurde
%-------------------------------------------------------------------------------------------------------------------------------

proof_mark(Adtgraph,Quelle,Senke,Modus) -> proof_mark(Adtgraph,Quelle,Senke,Modus,adtgraph:getValV(Adtgraph,Quelle,mark),adtgraph:getValV(Adtgraph,Senke,mark)).
proof_mark(AG,Q,S,_M,IstQMarkiert,IstSMarkiert) when IstQMarkiert == nil, IstSMarkiert == nil, Q == 0, S == 0 -> adtgraph:getEdges(AG); 
proof_mark(AG,Q,S,M,IstQMarkiert,IstSMarkiert) when IstQMarkiert == nil, IstSMarkiert == nil -> setze_markierung(AG,Q,S,M);
proof_mark(AG,Q,S,_M,IstQMarkiert,_IstSMarkiert) when IstQMarkiert /= nil -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,adtgraph:getVertices(AG));
proof_mark(AG,Q,S,_M,_IstQMarkiert,IstSMarkiert) when IstSMarkiert /= nil -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,adtgraph:getVertices(AG)).

%-------------------------------------------------------------------------------------------------------------------------------
% Setzt die Markerierung mit fortlaufender Nummer
%-------------------------------------------------------------------------------------------------------------------------------

setze_markierung(Adtgraph,Quelle,Senke,Mode) -> setze_markierung(Adtgraph,Quelle,Senke,Mode,adtgraph:getValV(Adtgraph,0,check),adtgraph:getValV(Adtgraph,Quelle,mark),adtgraph:getValV(Adtgraph,Senke,mark),0).  					%aufsplitten der Aufgaben                                    %lieber kleine schritte um die großen Sprünge zu wagen
setze_markierung(AG,Q,S,M,N,QMARK,SMARK,Counter) when N == nil -> setze_markierung(adtgraph:setAtV(AG,0,check,1),Q,S,M,adtgraph:getValV(AG,0,check),QMARK,SMARK,Counter+1);
setze_markierung(AG,Q,S,M,N,QM,SM,C) when M == 2, N /= nil, C == 0 -> setze_markierung(AG,Q,S,M,N+1,QM,SM,M);							%probleme mit der Markerierung durch Funktion die als Parameter 
setze_markierung(AG,Q,S,M,N,QM,SM,C) when M == 4, N /= nil, C == 0 -> setze_markierung(AG,Q,S,M,N,QM,SM,M);	
setze_markierung(AG,Q,S,M,N,QM,SM,C) when QM == nil -> setze_markierung(adtgraph:setAtV(AG,Q,mark,N),Q,S,M,N,adtgraph:getValV(AG,Q,mark),SM,C+1);										%seiteneffekt
setze_markierung(AG,Q,S,M,N,QM,SM,C) when SM == nil -> setze_markierung(adtgraph:setAtV(AG,S,mark,N+1),Q,S,M,N,QM,adtgraph:getValV(AG,S,mark),C+1);
setze_markierung(AG,Q,S,M,N,QM,SM,C) when C == 6, SM > QM -> setze_markierung(adtgraph:setAtV(AG,0,check,SM),Q,S,M,N,QM,SM,C+1); 
setze_markierung(AG,Q,S,M,N,QM,SM,C) when C == 6, SM < QM -> setze_markierung(adtgraph:setAtV(AG,0,check,QM),Q,S,M,N,QM,SM,C+1); 
setze_markierung(AG,Q,S,M,N,QM,SM,C) when C == 6, SM > QM -> setze_markierung(adtgraph:setAtV(AG,0,check,SM),Q,S,M,N,QM,SM,C+1); 
setze_markierung(AG,Q,S,M,N,QM,SM,C) when C == 6, SM < QM -> setze_markierung(adtgraph:setAtV(AG,0,check,QM),Q,S,M,N,QM,SM,C+1); 
setze_markierung(AG,Q,S,_M,_N,QM,SM,C) when C == 7, SM < QM -> wurden_alle_quellen_markiert(adtgraph:setAtE(AG,Q,S,marked,QM),Q,S,adtgraph:getVertices(AG));					%grenzen gestoßen an Funktions Aufruf : adtgraph:getVertices(adtgraph:setAtE(AG,Q,S,kantenanzahl,Anz+1))
setze_markierung(AG,Q,S,_M,_N,QM,SM,C) when C == 7, SM > QM -> wurden_alle_quellen_markiert(adtgraph:setAtE(AG,Q,S,marked,SM),Q,S,adtgraph:getVertices(AG)).

%-------------------------------------------------------------------------------------------------------------------------------
% Prüf ob alle Quellen mit 1 markiert wurden, Setzt die Senke auf 1 dessen Kante von Graph gelöscht wird auf Grund eines Zyklus
%-------------------------------------------------------------------------------------------------------------------------------

wurden_alle_quellen_markiert(Adtgraph,Q,S,Vertices) -> wurden_alle_quellen_markiert(Adtgraph,Q,S,Vertices,0,adtgraph:getValV(Adtgraph,0,counter)).
wurden_alle_quellen_markiert(AG,_Q,_S,[],Counter1,_Counter2) -> findmincost(adtgraph:setAtV(AG,0,counter,Counter1));
wurden_alle_quellen_markiert(AG,Q,S,[H|T],C1,C2) -> 
QuelleMarked = adtgraph:getValV(AG,Q,mark),
SenkeMarked = adtgraph:getValV(AG,S,mark),
MARKED = adtgraph:getValV(AG,H,mark),
N = adtgraph:getValV(AG,0,check),
AnzederKanten = adtgraph:getValV(AG,0,kantenanzahl),
AnzderEcken = zaehleallecken(AG,adtgraph:getVertices(AG)),
if
	C2 == nil, H == Q,  QuelleMarked == 1, MARKED == 1 -> wurden_alle_quellen_markiert(AG,Q,S,T,C1+1,C2);  % auf Seiteneffeckt achten
    H == Q, SenkeMarked == 1,  QuelleMarked == 1, MARKED == 1 -> wurden_alle_quellen_markiert(adtgraph:deleteEdge(AG,Q,S),Q,S,T,C1,C2);
	AnzderEcken == AnzederKanten+1 -> setze_markierungmit1(adtgraph:deleteEdge(AG,Q,S),adtgraph:getVertices(AG),Q,S);
	H == Q, QuelleMarked /= 1, SenkeMarked /= 1 -> wurden_alle_quellen_markiert(adtgraph:setAtV(AG,Q,mark,1),Q,S,T,C1,C2);
	H == Q, QuelleMarked == 1, SenkeMarked /= 1 -> wurden_alle_quellen_markiert(adtgraph:setAtE(AG,Q,S,marked,N+1),Q,S,T,C1,C2); 
	true -> wurden_alle_quellen_markiert(adtgraph:setAtV(AG,0,check,N),Q,S,T,C1,C2)
end.

%-------------------------------------------------------------------------------------------------------------------------------
% Prüf ob alle Ecken schon markiert wurden
%-------------------------------------------------------------------------------------------------------------------------------

pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,Vertices) -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,Vertices,0,0).
pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,[],_Check,_AlleEckenNichtmarkiert) -> setze_markierung(AG,Q,S,4);
pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,[H|T],Check,AE) -> 
GetValue = adtgraph:getValV(AG,H,mark),
QMARK = adtgraph:getValV(AG,Q,mark),
SMARK = adtgraph:getValV(AG,S,mark),
MarkCheck = adtgraph:getValV(AG,0,check),
if
	T == [], QMARK == nil, SMARK /= nil -> pruefe_ob_alleeckenmarkiertwurden(adtgraph:setAtV(AG,0,check,MarkCheck+1),Q,S,T,Check,AE);
	T == [], QMARK /= nil, SMARK /= nil -> wurden_alle_quellen_markiert(AG,Q,S,adtgraph:getVertices(AG)); 
	T == [], AE == 0, QMARK /= nil, SMARK /= nil-> wurden_alle_quellen_markiert(AG,Q,S,adtgraph:getVertices(AG));
	GetValue == nil -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,T,0,AE+1);
	GetValue /= nil -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,T,1,AE);
	true -> pruefe_ob_alleeckenmarkiertwurden(AG,Q,S,T,Check,AE)
end.

%-------------------------------------------------------------------------------------------------------------------------------
% Setzt die Markerierung mit Nummer 1
%-------------------------------------------------------------------------------------------------------------------------------

setze_markierungmit1(Adtgraph,Ecken,Quelle,Senke) -> setze_markierungmit1(Adtgraph,Ecken,Quelle,Senke,[]).
setze_markierungmit1(AG,[],_Q,_S,_List) -> findmincost(AG);
setze_markierungmit1(AG,[H|T],Q,S,L) ->
Is_marked_with1 = adtgraph:getValV(AG,H,mark),
if
  Is_marked_with1 == 1 ->
     if
       H == S -> findmincost(AG);
       true -> setze_markierungmit1(AG,T,Q,S,L)																										%wenn nichts zutrifft suche weiter
      end;
  Is_marked_with1 /= 1 ->  
      if
       H == S -> setze_markierungmit1(adtgraph:setAtV(AG,H,mark,1),T,Q,S,L);
       true -> setze_markierungmit1(AG,T,Q,S,L)
      end;
 true -> setze_markierungmit1(AG,T,Q,S,L)
end.

%-------------------------------------------------------------------------------------------------------------------------------
% Hilfsfunktion Zählt die Anzahl der Ecken
%-------------------------------------------------------------------------------------------------------------------------------

zaehleallecken(AG,Vertices) -> zaehleallecken(AG,Vertices,0).
zaehleallecken(_AG,[],Anz) -> Anz;
zaehleallecken(AG,[_H|T],Anz) -> zaehleallecken(AG,T,Anz+1).







