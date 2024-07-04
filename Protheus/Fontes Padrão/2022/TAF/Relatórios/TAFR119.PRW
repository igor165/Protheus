#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#Include "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TAFR119.CH"

/*/{Protheus.doc} TAFRXMLCMP()
	Imprime a diferença do XML de entrada com o 
	seu respectivo cadastro na base do taf
    @author user Henrique Pereira; Anieli Rodrigues
    @since date 19/08/2018
     /*/
Function TAFR119()
	TafXDescont(STR0021)  //"TAFR119 - Rastreamento de XML"
return