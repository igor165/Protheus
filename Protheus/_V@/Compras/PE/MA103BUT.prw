#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

//****************************************************************
// BOTAO PARA INFORMACOES ADICIONAIS
//****************************************************************
User Function MA103BUT() //DOCUMENTO DE ENTRADA
Local aBut := {} 
Public    cObsMT103        := IIF( Inclui, Space(300), SF1->F1_MENNOTA )
    
    // Ponto de chamada Conex�oNF-e sempre como primeira instru��o.
    aButtons := U_GTPE014()
    
    aAdd(aBut,{ "NOTE"		, {||u_FSTelaObs("SF1")}, "Observacoes", "Obs.NF"}) 
    aAdd(aBut,{ "BOLETO"	, {||u_VACOMI01()}       , "Boletos lllll" } )  
Return( aBut ) 
