#include "PROTHEUS.CH"
#include "ERROR.CH"
#include "CTBXOLD.CH"


STATIC aSitEsp
STATIC aOutraInsc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณSitEsp    ณ Autor ณEduardo Nunes Cirqueiraณ Data ณ 27/08/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณApresenta tela para escolha da Situacao Especial na geracao ณฑฑ
ฑฑณ          ณdo SPED Contabil.                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณLogico                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function SitEsp()

Local 	aSitEsp := {	{"Z","Normal"}		 	,; 
					{"0","Abertura"}	 	,;
					{"1","Cisใo"}		 	,;
					{"2","Fusใo"}		 	,;
					{"3","Incorpora็ใo"}	,;
					{"4","Extin็ใo"}	}		
Local lOk

lOk := CtbOpcSX5(aSitEsp)

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSitEspConsบAutor  ณEduardo Nunes Cirqueira บ Data ณ  27/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorno para consulta padrao CTBSP1 acima                       บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SitEspCons()
Local cVar := Upper( Alltrim( ReadVar() ) )
Return (M->&(cVar))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOutraInscrณ Autor ณEduardo Nunes Cirqueiraณ Data ณ 27/08/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณApresenta tela para escolha de Outras Inscricoes na geracao ณฑฑ
ฑฑณ          ณdo SPED Contabil.                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณLogico                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function OutraInscr()

Local 	aOutraInsc := {	{"00","Nใo hแ"}		 							,;
					{"01","Banco Central do Brasil/BACEN"}				,;
					{"02","Superintend๊ncia de Seguros Privados/SUSEP"}	,;
					{"03","Comissใo de Valores Mobiliแrios/CVM"}		,;
					{"04","Secretaria de Previd๊ncia complementar"}	}
Local lOk

lOk := CtbOpcSX5(aOutraInsc)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณOutraInConsบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorno para consulta padrao CTBSP2 acima                       บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OutraInCons()
Local cVar:= Upper( Alltrim( ReadVar() ) )

Return (M->&(cVar))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณExistSitEspบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do parametro "Situacao Especial"                      บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Conteudo do parametro                                          บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExistSitEsp(cConteudo)

Local lRet := .T.

If ! (cConteudo $ "Z01234")
	Help(" ",1,"CT5SEM1",,STR0001+": "+STR0002,1,0)//	"Situacao Especial"##"Conteudo Invalido. Pressione F3 e veja as opcoes para este campo.")
	lRet := .F.
EndIf
     
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbOpcSX5 บAutor  ณAlvaro Camillo Neto บ Data ณ  23/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que simula o comportamento da tela de SX5            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbOpcSX5(aPars)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oListBox
Local oPanel
Local cVar	    := Upper( Alltrim( ReadVar() ) )
Local cConteudo := ""
Local cCodigo   := ""
Local nPosList  := 0
Local lOk		:= .F.

cConteudo := &(ReadVar())
If !Empty(cConteudo)
	nPosList := ASCAN(aPars, {|aVal| aVal[1] == Upper(cConteudo)})
EndIf


DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa") //"Pesquisa"

oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{STR0003,STR0004},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Codigo"###"Outras Inscricoes"
oListBox:SetArray(aPars)
oListBox:bLine := { ||{aPars[oListBox:nAT][1],aPars[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
oListBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 115,05 BUTTON oConf Prompt STR0005 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,cCodigo:=aPars[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL //'Confirma'
@ 115,55 BUTTON oCanc Prompt STR0006 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL //'Cancela'

If nPosList > 0
	oListBox:nAT   := nPosList
	oListBox:bLine := { ||{aPars[oListBox:nAT][1],aPars[oListBox:nAT][2]}}
	oConf:SetFocus()
EndIf

ACTIVATE MSDIALOG oDlg CENTERED

If lOk
	M->&(cVar) := cCodigo	
Else
	M->&(cVar) := cConteudo
EndIf

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณExistOutrInsบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do parametro "Outras Inscricoes"                      บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Conteudo do parametro                                          บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExistOutrIns(cConteudo)

Local lRet := .T.

If ! (cConteudo $ "00#01#02#03#04")
	Help(" ",1,"CT5SEM2",,STR0004+": "+STR0002,1,0)//	"Outras Inscricoes"##"Conteudo Invalido. Pressione F3 e veja as opcoes para este campo."
	lRet := .F.
EndIf
     
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  14/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com a das inicial e a data final da apura็ใo  บฑฑ
ฑฑบ          ณde acordo com o periodo informado.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function dtIniFin(tpPeriodo, cAno)
Local aDtIniFin := {CTOD("  /  /  "),CTOD("  /  /  ")}
Local dtIni     := CTOD("  /  /  ")
Local dtFim 	:= CTOD("  /  /  ")

If tpPeriodo=="A00"
	dtIni  := CTOD("01/01/"+cAno)
   	dtFim := CTOD("31/12/"+cAno)
   	aDtIniFin[1] := dtIni
   	aDtIniFin[2] := dtFim
   	
	ElseIf tpPeriodo=="T01"
		dtIni  := CTOD("01/01/"+cAno)
   		dtFim  := CTOD("31/03/"+cAno)
   		aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim

	ElseIf tpPeriodo=="T02"          
		dtIni  := CTOD("01/04/"+cAno)
   		dtFim  := CTOD("30/06/"+cAno)
		aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim
	ElseIf tpPeriodo=="T03"
		dtIni  := CTOD("01/07/"+cAno)
	   	dtFim  := CTOD("30/09/"+cAno)
	   	aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim

	ElseIf tpPeriodo=="T04"
		dtIni  := CTOD("01/10/"+cAno)
	   	dtFim  := CTOD("31/12/"+cAno)
	   	aDtIniFin[1] := dtIni
	   	aDtIniFin[2] := dtFim
	Else
      	dtIni     := CTOD("  /  /  ")
		dtFim     := CTOD("  /  /  ")
		aDtIniFin[1] := dtIni
	   	aDtIniFin[2] := dtFim
EndIf


return aDtIniFin


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  18/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a valida็ใo dos campos preenchidos pelos usuแrios    บฑฑ
ฑฑบ          ณ									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fContVld(aParamFco)
Local aContRef  := {}
Local aConoutR 	:= {}
Local aCtbMoeda := {} // Moeda?
Local lAbort   	:= .F. 
Local nCont
Local cContaIni := aParamFco[2][1]
Local cContaFim := Iif( !Empty( aParamFco[2][2] ) , aParamFco[2][2] , Replicate( "Z" , 20 ) )

aAdd(aConoutR, "Parametros do Wizard" )

//valida se o ano de apura็ใo foi preenchido
If Empty(aParamFco[1][1])
	aAdd(aConoutR, Padr( "Ano de Apura็ใo" , 28 , "" ) + " --> Parโmetro nใo preenchido" )
EndIf

If SUBSTRING(aParamFco[1][2],1,1) != "Z" .And. (Empty(_aTotal[001]) .Or. Empty(_aTotal[002]))
	aAdd(aConoutR, Padr( "Data Escritura็ใo" , 28 , "" ) + " --> Data inicial e/ou final obrigat๓ria, devido a Sit. Especial ser diferente de Z-Normal" )	
EndIf
//Se o Tipo de escritura็ใo estiver como sim o campo Recibo Anterior deve ser preenchido
If SUBSTRING(_aTotal[037][1][3],1,1)=="1" .And. Empty(aParamFco[1][5])
   aAdd(aConoutR, Padr( "N๚mero do Recibo" , 28) + " --> O tipo de Escritura็ใo estแ marcado como retificadora," )
   aAdd(aConoutR, Padr( "                " , 28) + " --> sendo assim, o campo N๚mero do Recibo anterior deve ser preenchido ")
Endif

//valida se o tipo de saldo foi preenchido ou existente
If Empty(aParamFco[2][4])
	aAdd(aConoutR, Padr( "Tipo de Saldo Balancete" , 28 ) + " --> Parโmetro nใo preenchido" )
ElseIf !VldTpSald( aParamFco[2][4] )
	aAdd(aConoutR, Padr( "Tipo de Saldo Balancete" , 28 ) + " --> Nใo existe")
EndIf

//valida se conta de apura็ใo foi preenchido
If Empty(aParamFco[3][1])
   aAdd(aConoutR, Padr( "Conta de Apura็ใo" , 28 ) + " --> Parโmetro nใo preenchido")
EndIf 

aCtbMoeda := CtbMoeda(aParamFco[2][3])

//valida se a moeda foi preenchido ou existente
If Empty(aParamFco[2][3])
   aAdd(aConoutR, Padr( "Moeda" , 28 ) + " --> Parโmetro nใo preenchido")
Endif

If Empty(aCtbMoeda[1])
	aAdd(aConoutR, Padr( "Moeda" , 28 ) + " --> Nใo existe")
Endif

//valida se a data de apura็ใo foipreenchido
If Empty(aParamFco[3][3])
   aAdd(aConoutR, Padr( "Data L/P" , 28 ) + " --> Parโmetro nใo preenchido")
EndIf 

//verifica se a conta analitica possui conta referencial
If SUBSTRING(aParamFco[1][4],1,2) != "00"
	aContRef := CtaRefVld(cContaIni,cContaFim) 
EndIf

If SUBSTRING(aParamFco[4][1],1,1)=="1"
	//valida se o tipo de saldo de espurgo
	If Empty(aParamFco[4][2])
		aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo" , 28 ) + " --> Parโmetro nใo preenchido" )
	ElseIf !VldTpSald( aParamFco[4][2] )
		aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo" , 28 ) + " --> Nใo existe")
	EndIf 

	//valida se o tipo de saldo de inclusao
	If Empty(aParamFco[4][3])
		aAdd(aConoutR, Padr( "Tipo de Saldo de Inclusใo" , 28 ) + " --> Parโmetro nใo preenchido" )
	ElseIf !VldTpSald( aParamFco[4][3] )
		aAdd(aConoutR, Padr( "Tipo de Saldo de Inclusใo" , 28 ) + " --> Nใo existe")
	EndIf 
	
	If !Empty(aParamFco[4][2]) .And. !Empty(aParamFco[4][3])
		If aParamFco[4][2] == aParamFco[4][3]
			aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo e Inclusใo" , 40 ) + " --> Os parโmetros nใo podem ser iguais")
		EndIf     
	EndIf 
	
EndIf



//verifica se a conta analitica possui conta referencial
If ! Empty(aContRef)
	aAdd(aConoutR, " " )
	aAdd(aConoutR, "Valida็ใo do Plano de Contas" )
	For nCont := 1 to Len(aContRef)
		aAdd(aConoutR, aContRef[nCont])
	Next
EndIf

lAbort := ( Len( aConoutR ) > 1 )

If lAbort
	CtRConOut(aConoutR)
EndIf

Return lAbort  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  18/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se as contas analiticasดpossuem contas referenciais  บฑฑ
ฑฑบ          ณ									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtaRefVld(cContaIni, cContaFim)
Local aContRef := {}
Local cQuery   := ""

DEFAULT cContaIni := Space(20)
DEFAULT cContaFim := Replicate( "Z" , 20 )

cQuery := "SELECT CT1.CT1_CONTA, CT1.CT1_DESC01, 'CONTA CONTABIL SEM REFERENCIAL' AS MSG "
cQuery += "  FROM " + RetSQLTab( "CT1" )
cQuery += " WHERE " + RetSQLCond( "CT1" )
cQuery += "   AND CT1.CT1_CLASSE = '2'"
cQuery += "   AND CT1.CT1_NTSPED != '05'"
cQuery += "   AND CT1.CT1_NTSPED != '09'"
	
IF cContaIni == cContaFim
	cQuery += " AND CT1_CONTA = '" + cContaIni + "'"
Else
	IF !Empty( cContaIni ) 
		cQuery += " AND CT1_CONTA >= '" + cContaIni + "'"
	Endif
	IF !Empty( cContaFim )
		cQuery += " AND CT1_CONTA <= '" + cContaFim + "'"
	Endif
Endif

cQuery += " AND NOT EXISTS(" 
cQuery += "                 SELECT R_E_C_N_O_ "
cQuery += "                   FROM " + RetSQLTab( "CVD" ) + " "
cQuery += "                  WHERE CVD.CVD_FILIAL = '"+xFilial("CVD")+"'"
cQuery += "                    AND CT1.CT1_CONTA = CVD.CVD_CONTA "
cQuery += "                    AND CVD.D_E_L_E_T_ = ' '"
cQuery += "                )"

cQuery := ChangeQuery( cQuery )
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRYREF",.T.,.T.)

DbSelectArea( 'TMPQRYREF' )
TMPQRYREF->(DbGoTop())

While TMPQRYREF->( ! Eof() )

	aAdd(aContRef, TMPQRYREF->CT1_CONTA + " - " + TMPQRYREF->CT1_DESC01 + " --> " +  TMPQRYREF->MSG )
	
	DbSelectArea( 'TMPQRYREF' )
	TMPQRYREF->(DbSkip())
ENDDO

  
Return aContRef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFcontFilial บAutor ณElton da C. Santana บ Data ณ 20/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณretorna as Filiais selecionadas 		  					  บฑฑ
ฑฑบ          ณ                                                			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FcontFilial(aFilSel)

Local aArea  	:= GetArea()
Local aRetFil 	:= {}
Local i 		:= 0

Default aFilSel := {}
                
For i := 1 To Len(aFilSel)
    If aFilSel[i][1]
    	Aadd(aRetFil,aFilSel[i][2])
    EndIf 
Next   

RestArea(aArea)

Return aRetFil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหอออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLctoCtaXCustoบAutor  ณElton da C. Santana บData ณ23/06/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสอออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o C.Custo existe para amarra็ใo da Conta x 	  บฑฑ
ฑฑบ          ณConta Ref.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LctoCtaXCusto(cConta, cCusto  )
Local aArea  	:= GetArea() 
Local cQuery	:= ""
Local cAliasProc:= ''
Local lRet		:= .F.

// Inicializa o processamento
cQuery := "SELECT COUNT(*) CONTCVD FROM "+RetSqlName("CVD")+" ";
+" WHERE CVD_FILIAL = '"+xFilial("CVD")+"' ";
+" AND D_E_L_E_T_ = ' ' ";
+" AND CVD_CONTA = '"+cConta+"' ";
+" AND CVD_CUSTO = '"+cCusto+"' "
	
cQuery := ChangeQuery( cQuery )
	
cAliasProc := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasProc,.T.,.T.)
	
If (cAliasProc)->CONTCVD >0
	lRet := .T.
EndIf
	
If Select( cAliasProc ) > 0
	DbSelectArea( cAliasProc )
	dbCloseArea()
EndIf
									
RestArea(aArea)

Return lRet






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtJobInd บAutor  ณAlvaro Camillo Neto บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Job                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtJobInd(cEmpX,cFilDe,cFilAte,cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cMoedaDe,cMoedaAte)

Local lRet		 := .T.

DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilDe,,,,,)

lRet := CtGerInd(cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtGerInd บAutor  ณAlvaro Camillo Neto  บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado na visใo gerenci บฑฑ
ฑฑบ          ณ al                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtGerInd(cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
Local lRet := .T.
Local aSM0 := Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil := 0
Local aStruSQL	:= {}
Local cChave	:= "EMPRESA+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA"
Local aRegs		:= 0
Local cFilOri	:= cFilAnt
Local nX		   := 0
Local nZ			:= 0
Local nMoedas	:= 0
Local aMoedas	:= {}
Local nFator

Default cSaldo	:= '1'
DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return .F.
Endif

//Array de Moedas
nMoedas	:= CtbMoedas()

If Empty(cMoedaDe)
	cMoedaDe := '01'
EndIf

For nX := 1 to nMoedas
	cMoeda := StrZero(nX,2)
	If cMoeda >= cMoedaDe .And. cMoeda <= cMoedaAte 
		aAdd(aMoedas,cMoeda)
	EndIf
Next nX

//Cria Tabela Temporแria
AADD(aStruSQL,{"EMPRESA","C",02,00})
AADD(aStruSQL,{"FILIAL","C",TamSx3("CT1_FILIAL")[1],00})
AADD(aStruSQL,{"DATAMOV","D",08,00})
AADD(aStruSQL,{"MOEDA","C",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"CONTA","C",TamSx3("CT1_CONTA")[1],00})
AADD(aStruSQL,{"DESCRICAO","C",TamSx3("CT1_DESC01")[1],00})
AADD(aStruSQL,{"SALDOATU","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOACM","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDODEB","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOCRD","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOATU2","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOANT","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"MOVIMENTO","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})

If Select(cAliasTRB) > 0
	(cAliasTRB)->(dbCloseArea())
EndIf

MsErase(cAliasTRB)
MsCreate(cAliasTRB, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasTRB, cAliasTRB, .T., .F. )
//Cria o Indice
IndRegua(cAliasTRB,cAliasTRB,cChave,,)

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	For nZ := 1 To Len(aMoedas)
		aRegs := GetSldInd( cAnoMes, cSetOfBook , aMoedas[nZ], aMoedas[nZ] , , cSaldo , , , .T., .T., , .T.)
		             
		For nX := 1 to Len(aRegs)
			nSaldoAtual := aRegs[nX][3] - aRegs[nX][4] // Debito - Credito
			nSaldoACM   := aRegs[nX][5]
			nFator		:= 1
			
			If aRegs[nX][9] == '1' // Conta Natureza Devedora 
				nSaldoAtual :=	nSaldoAtual
				nSaldoACM   := -1 * (nSaldoACM)	
				nFator		:= -1
			EndIf
			
			If aRegs[nX][9] == '2' // Conta Natureza Credora
				nSaldoAtual :=	-1 * nSaldoAtual
				nSaldoACM   := (nSaldoACM)	
			EndIf
			
			If (cAliasTRB)->(MsSeek(cEmpAnt + cFilAnt + DToS(aRegs[nX][1]) + aMoedas[nZ] + aRegs[nX][2] ))
				RecLock(cAliasTRB,.F.)
				(cAliasTRB)->SALDOATU += nSaldoAtual 
				(cAliasTRB)->SALDOACM += nSaldoACM
				(cAliasTRB)->SALDOANT  += nFator * aRegs[nX][10]
				(cAliasTRB)->SALDODEB  += nFator * aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  += nFator * aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 += nFator * aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO += nFator * aRegs[nX][11]
				MsUnlock()
			Else
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->EMPRESA := cEmpAnt
				(cAliasTRB)->FILIAL  := cFilAnt
				(cAliasTRB)->DATAMOV :=	aRegs[nX][1]
				(cAliasTRB)->MOEDA   := aMoedas[nZ]
				(cAliasTRB)->CONTA   := aRegs[nX][2]
				(cAliasTRB)->DESCRICAO:= aRegs[nX][6]
				(cAliasTRB)->SALDOATU := nSaldoAtual 
				(cAliasTRB)->SALDOACM := nSaldoACM 
				(cAliasTRB)->SALDOANT  := nFator * aRegs[nX][10]
				(cAliasTRB)->SALDODEB  := nFator * aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  := nFator * aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 := nFator * aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO := nFator * aRegs[nX][11]
				MsUnlock()
			EndIf
		Next nX
	Next nZ
	
Next nContFil

cFilAnt := cFilOri

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSldInd   บAutor ณAlvaro Camillo Neto    บ Data ณ 26/08/10บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o saldo das vis๕es gerenciais de varios perํodos    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GetSldInd(cAnoMes, cSetOfBook, cMoeda, cMoedaDesc, lConsSaldo, cSaldos,;
cHeader, dDataLP, lVlrZerado, lMovPeriodo, lPlGerSint, lNImpMov, lImpAntLP)

Local nX          := 01
Local lAbs       := .F.
Local lTdsRgs    := .T.
Local nTmArray   := 00
Local aRetOrig   := {}
Local aCTSArea   := {}
Local aSetOfBook := CtbSetOf(cSetOfBook)
Local aRetorno	  := {}
Local dDtIni
Local dDtFim
Default cMoeda      := '01'
Default cMoedaDesc  := '01'
Default lConsSaldo  := .F.
Default cSaldos     := '1'
Default cHeader     := ''
Default dDataLP     := Nil
Default lVlrZerado  := .T.
Default lMovPeriodo := .F.
Default lPlGerSint  := .T.
Default lNImpMov    := .T.
Default lImpAntLP   := .F.

//------------------------------------------------------------//
// Localiza o maior codigo da visใo gerencial em questใo      //
//------------------------------------------------------------//
aCTSArea := CTS->(GetArea())
CTS->(DbSetOrder(2))
CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]+Replicate("Z",TamSx3("CTS_CONTAG")[1]),.T.))
If CTS->CTS_CODPLA != cSetOfBook
	CTS->(DbSkip(-1))
EndIf
nTmArray := Val(CTS->CTS_CONTAG)
CTS->(RestArea(aCTSArea))

//------------------------------------------------------------//
// Carrega array conforme parametros e exclui arrays em branco//
//------------------------------------------------------------//
dDtIni := STOD(cAnoMes+'01')
dDtFim := LastDay(dDtIni)
aRetOrig := GetSldPlGer( cSetOfBook, dDtIni, dDtFim, cMoeda, nTmArray, lAbs, lTdsRgs, cSaldos, lNImpMov, cHeader, lImpAntLP, dDataLP, lVlrZerado, cMoedaDesc, lMovPeriodo, lPlGerSint, lConsSaldo)
For nX := 1 to Len(aRetOrig)
	aAdd(aRetorno,{dDtFim, aRetOrig[nX][1], aRetOrig[nX][2], aRetOrig[nX][3], aRetOrig[nX][4], aRetOrig[nX][5], aRetOrig[nX][6], aRetOrig[nX][7], aRetOrig[nX][8], aRetOrig[nX][9], aRetOrig[nX][10] } )
Next nX

Return(aRetorno)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtJobInd2บAutor  ณMarcelo Akama		 บ Data ณ  12/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Job                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtJobInd2(cEmpX,cFilDe,cFilAte,cAnoMes,cSetOfBook,cAliasCON,cAliasORC,cMoedaDe,cMoedaAte)
Local lRet		:= .T.

DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilDe,,,,,)

//Real
If !CtGerIndC(cAnoMes,cSetOfBook,cAliasCON,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
	lRet := .F.
EndIf

//Orcado e Empenhado
If !CtGerIndO(cAnoMes,cSetOfBook,cAliasORC,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtGerIndCบAutor  ณMarcelo Akama        บ Data ณ  03/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado na visใo gerenci บฑฑ
ฑฑบ          ณ al (Contabilidade)                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtGerIndC(cAnoMes,cSetOfBook,cAliasCON,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
Local lRet		:= .T.
Local cAliasTRB := CriaTrab(nil,.F.)
Local aStruSQL	:= {}
Local lGestCorp	:= .F.

DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
EndIf

//Cria Tabela Temporแria Contabilidade
aStruSQL := {}
If lGestCorp
	AADD(aStruSQL,{"HL9_EMPRES","C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"HL9_UNIDAD","C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"HL9_FILIAL","C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"HL9_EMPRES","C",02,00})
	AADD(aStruSQL,{"HL9_UNIDAD","C",02,00})
	AADD(aStruSQL,{"HL9_FILIAL","C",TamSx3("CT2_FILIAL")[1],00})
EndIf

AADD(aStruSQL,{"HL9_PLCONT","C",TamSx3("CTS_CODPLA")[1],00})
AADD(aStruSQL,{"HL9_CNTCTB","C",TamSx3("CT2_DEBITO")[1],00})
AADD(aStruSQL,{"HL9_CCUSTO","C",TamSx3("CT2_CCD")[1],00})
AADD(aStruSQL,{"HL9_MOEDA" ,"N",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"HL9_DATA"  ,"D",08,00})
AADD(aStruSQL,{"HL9_VCTBRL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VSDINI","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VDREAL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VCREAL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VSDFIN","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})

If Select(cAliasCON) > 0
	(cAliasCON)->(dbCloseArea())
EndIf

MsErase(cAliasCON)
MsCreate(cAliasCON, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasCON, cAliasCON, .T., .F. )

//Real
If CtGerInd(cAnoMes,'1',cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		dbSelectArea(cAliasCON)
		RecLock(cAliasCON,.T.)
		(cAliasCON)->HL9_EMPRES := (cAliasTRB)->EMPRESA
		(cAliasCON)->HL9_UNIDAD := (cAliasTRB)->UNIDADE
		(cAliasCON)->HL9_FILIAL := (cAliasTRB)->FILIAL
		(cAliasCON)->HL9_PLCONT := cSetOfBook
		(cAliasCON)->HL9_CNTCTB := (cAliasTRB)->CONTA
		(cAliasCON)->HL9_CCUSTO := ''
		(cAliasCON)->HL9_MOEDA  := Val((cAliasTRB)->MOEDA)
		(cAliasCON)->HL9_DATA   := (cAliasTRB)->DATAMOV
		(cAliasCON)->HL9_VCTBRL := (cAliasTRB)->MOVIMENTO
		(cAliasCON)->HL9_VSDINI := (cAliasTRB)->SALDOANT
		(cAliasCON)->HL9_VDREAL := (cAliasTRB)->SALDODEB
		(cAliasCON)->HL9_VCREAL := (cAliasTRB)->SALDOCRD
		(cAliasCON)->HL9_VSDFIN := (cAliasTRB)->SALDOATU2
		MsUnlock()
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(dbSkip())
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtGerIndOบAutor  ณMarcelo Akama        บ Data ณ  03/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado na visใo gerenci บฑฑ
ฑฑบ          ณ al (Orcado)                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtGerIndO(cAnoMes,cSetOfBook,cAliasORC,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
Local lRet		:= .T.
Local cAliasTRB := CriaTrab(nil,.F.)
Local aStruSQL	:= {}
Local lGestCorp := .F.

DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
EndIf

//Cria Tabela Temporแria Orcamento
aStruSQL := {}
If lGestCorp
	AADD(aStruSQL,{"HLC_EMPRES","C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"HLC_UNIDAD","C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"HLC_FILIAL","C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"HLC_EMPRES","C",02,00})
	AADD(aStruSQL,{"HLC_UNIDAD","C",02,00})
	AADD(aStruSQL,{"HLC_FILIAL","C",TamSx3("CT2_FILIAL")[1],00})
EndIf

AADD(aStruSQL,{"HLC_PLCONT","C",TamSx3("CTS_CODPLA")[1],00})
AADD(aStruSQL,{"HLC_CNTCTB","C",TamSx3("CT2_DEBITO")[1],00})
AADD(aStruSQL,{"HLC_CCUSTO","C",TamSx3("CT2_CCD")[1],00})
AADD(aStruSQL,{"HLC_ITEM"  ,"C",TamSx3("CTD_ITEM")[1],00})
AADD(aStruSQL,{"HLC_CLVL"  ,"C",TamSx3("CTH_CLVL")[1],00})
AADD(aStruSQL,{"HLC_MOEDA" ,"N",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"HLC_DATA"  ,"D",08,00})
AADD(aStruSQL,{"HLC_VORCAD","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HLC_VEMPEN","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})

If Select(cAliasORC) > 0
	(cAliasORC)->(dbCloseArea())
EndIf

MsErase(cAliasORC)
MsCreate(cAliasORC, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasORC, cAliasORC, .T., .F. )

//Orcado
If CtGerInd(cAnoMes,'0',cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		dbSelectArea(cAliasORC)
		RecLock(cAliasORC,.T.)
		(cAliasORC)->HLC_EMPRES := (cAliasTRB)->EMPRESA
		(cAliasORC)->HLC_UNIDAD := (cAliasTRB)->UNIDADE
		(cAliasORC)->HLC_FILIAL := (cAliasTRB)->FILIAL
		(cAliasORC)->HLC_PLCONT := cSetOfBook
		(cAliasORC)->HLC_CNTCTB := (cAliasTRB)->CONTA
		(cAliasORC)->HLC_CCUSTO := (cAliasTRB)->CCUSTO
		(cAliasORC)->HLC_ITEM 	:= (cAliasTRB)->ITEM
		(cAliasORC)->HLC_CLVL 	:= (cAliasTRB)->CLVL
		(cAliasORC)->HLC_MOEDA  := Val((cAliasTRB)->MOEDA)
		(cAliasORC)->HLC_DATA   := (cAliasTRB)->DATAMOV
		(cAliasORC)->HLC_VORCAD := (cAliasTRB)->MOVIMENTO
		(cAliasORC)->HLC_VEMPEN := 0
		MsUnlock()
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(dbSkip())
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf

//Empenhado
If CtGerInd(cAnoMes,'4',cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		dbSelectArea(cAliasORC)
		RecLock(cAliasORC,.T.)
		(cAliasORC)->HLC_EMPRES := (cAliasTRB)->EMPRESA
		(cAliasORC)->HLC_UNIDAD := (cAliasTRB)->UNIDADE
		(cAliasORC)->HLC_FILIAL := (cAliasTRB)->FILIAL
		(cAliasORC)->HLC_PLCONT := cSetOfBook
		(cAliasORC)->HLC_CNTCTB := (cAliasTRB)->CONTA
		(cAliasORC)->HLC_CCUSTO := ''
		(cAliasORC)->HLC_MOEDA  := Val((cAliasTRB)->MOEDA)
		(cAliasORC)->HLC_DATA   := (cAliasTRB)->DATAMOV
		(cAliasORC)->HLC_VORCAD := 0
		(cAliasORC)->HLC_VEMPEN := (cAliasTRB)->MOVIMENTO
		MsUnlock()
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(dbSkip())
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtCntIndO บAutor  ณMarcelo Akama       บ Data ณ  03/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado no plano de cnts บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCntIndO(cAnoMes,cAliasORC,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
Local lRet		:= .T.
Local cAliasTRB := CriaTrab(nil,.F.)
Local aStruSQL	:= {}
Local aTemp		:= {}
Local nReg		:= 0
Local nPos		:= 0
Local lGestCorp	:= .F.
Local nCpos		:= 0

DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'
DEFAULT lImpEnt		:= .F.

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
EndIf

AutoGrLog("Inํcio da Cria็ใo da Tabela dos Dados Contแbeis --> Tabela HLC - Saldos Contแbeis Or็ado/Empenhado - " + Time())

//Cria Tabela Temporแria Orcamento
aStruSQL := {}
If lGestCorp
	AADD(aStruSQL,{"HLC_EMPRES","C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"HLC_UNIDAD","C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"HLC_FILIAL","C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"HLC_EMPRES","C",02,00})
	AADD(aStruSQL,{"HLC_UNIDAD","C",02,00})
	AADD(aStruSQL,{"HLC_FILIAL","C",TamSx3("CT2_FILIAL")[1],00})
EndIf
AADD(aStruSQL,{"HLC_PLCONT","C",TamSx3("CTS_CODPLA")[1],00})
AADD(aStruSQL,{"HLC_CNTCTB","C",TamSx3("CT2_DEBITO")[1],00})
AADD(aStruSQL,{"HLC_CCUSTO","C",TamSx3("CT2_CCD")[1],00})
AADD(aStruSQL,{"HLC_ITEM"  ,"C",TamSx3("CT2_ITEMD")[1],00})
AADD(aStruSQL,{"HLC_CLVL"  ,"C",TamSx3("CT2_CLVLDB")[1],00})
AADD(aStruSQL,{"HLC_MOEDA" ,"N",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"HLC_DATA"  ,"D",08,00})
AADD(aStruSQL,{"HLC_VORCAD","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HLC_VEMPEN","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})

For nCpos := 1 To Len(aStruSQL)
	AutoGrLog("Cria็ใo do Campo " + aStruSQL[nCpos][1] + Time())
Next nCpos

If Select(cAliasORC) > 0
	(cAliasORC)->(dbCloseArea())
EndIf

AutoGrLog("Finaliza็ใo da Cria็ใo da Tabela dos Dados Contแbeis --> Tabela HLC - Saldos Contแbeis Or็ado/Empenhado - " + Time())

AutoGrLog("Apagando dados da tabela temporแria HLC - " + Time())
MsErase(cAliasORC)
AutoGrLog("Cria็ใo da tabela temporแria HLC na base de dados - " + Time())
MsCreate(cAliasORC, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasORC, cAliasORC, .T., .F. )

AutoGrLog("Buscando dados do or็ado da tabela temporแria HLC - " + Time())

//Orcado
If CtCntInd(cAnoMes,'0',cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		nPos := aScan( aTemp, { |x| x[1] + x[2] + x[4] + x[10] + x[11] + x[12] + StrZero( x[6], TamSX3( "CT2_MOEDLC" )[1] ) + DtoS( x[7] ) ==(cAliasTRB)->( EMPRESA + FILIAL + CONTA + CCUSTO + ITEM + CLVL + MOEDA + DtoS( DATAMOV ) ) } )
		If nPos <= 0
			aAdd( aTemp, { (cAliasTRB)->EMPRESA,;
			            (cAliasTRB)->FILIAL,;
			            "",;
			            (cAliasTRB)->CONTA,;
			            '',;
			            Val((cAliasTRB)->MOEDA),;
			            (cAliasTRB)->DATAMOV,;
			            (cAliasTRB)->MOVIMENTO,;
			            0,;
						(cAliasTRB)->CCUSTO,;
						(cAliasTRB)->ITEM,;
						(cAliasTRB)->CLVL,;
						(cAliasTRB)->UNIDADE;
					} )
		Else
			aTemp[nPos][8] += (cAliasTRB)->MOVIMENTO
		EndIf

		(cAliasTRB)->( !DbSkip() )
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf
AutoGrLog("Finalizado busca de dados do or็ado da tabela temporแria HLC - " + Time())

AutoGrLog("Buscando dados do empenado da tabela temporแria HLC - " + Time())
//Empenhado
If CtCntInd(cAnoMes,'4',cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		nPos := aScan( aTemp, { |x| x[1] + x[2] + x[4] + x[10] + x[11] + x[12] + StrZero( x[6], TamSX3( "CT2_MOEDLC" )[1] ) + DtoS( x[7] ) ==(cAliasTRB)->( EMPRESA + FILIAL + CONTA + CCUSTO + ITEM + CLVL + MOEDA + DtoS( DATAMOV ) ) } )
		If nPos <= 0
			aAdd( aTemp, { (cAliasTRB)->EMPRESA,;	//[1]
						(cAliasTRB)->FILIAL,;		//[2]
						"",;						//[3]
						(cAliasTRB)->CONTA,;		//[4]
						'',;						//[5]
						Val((cAliasTRB)->MOEDA),;	//[6]
						(cAliasTRB)->DATAMOV,;		//[7]
						0,;							//[8]
						(cAliasTRB)->MOVIMENTO,;	//[9]
						(cAliasTRB)->CCUSTO,;		//[10]
						(cAliasTRB)->ITEM,;			//[11]
						(cAliasTRB)->CLVL,;			//[12]
			   			(cAliasTRB)->UNIDADE;		//[13]
			   			} )
		Else
			aTemp[nPos][9] += (cAliasTRB)->MOVIMENTO
		EndIf

		(cAliasTRB)->( !DbSkip() )
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf

For nReg := 1 To Len( aTemp )
	dbSelectArea( cAliasORC )
	RecLock( cAliasORC, .T. )
	(cAliasORC)->HLC_EMPRES := aTemp[nReg][1]
	(cAliasORC)->HLC_UNIDAD := aTemp[nReg][13]
	(cAliasORC)->HLC_FILIAL := aTemp[nReg][2]
	(cAliasORC)->HLC_PLCONT := aTemp[nReg][3] // cSetOfBook
	(cAliasORC)->HLC_CNTCTB := aTemp[nReg][4]
	(cAliasORC)->HLC_CCUSTO := aTemp[nReg][10]
	(cAliasORC)->HLC_ITEM   := aTemp[nReg][11]
	(cAliasORC)->HLC_CLVL   := aTemp[nReg][12]
	(cAliasORC)->HLC_MOEDA  := aTemp[nReg][6]
	(cAliasORC)->HLC_DATA   := aTemp[nReg][7]
	(cAliasORC)->HLC_VORCAD := aTemp[nReg][8]
	(cAliasORC)->HLC_VEMPEN := aTemp[nReg][9]
	MsUnlock()
Next
AutoGrLog("Finalizado busca dados do empenado da tabela temporแria HLC - " + Time())

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtCntInd  บAutor  ณAlvaro Camillo Neto บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado no plano de cnts บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCntInd(cAnoMes,cSaldo,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
Local lRet 		:= .T.
Local aSM0 		:= Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil 	:= 0
Local aStruSQL	:= {}
Local cChave	:= "EMPRESA+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA+CCUSTO+ITEM+CLVL"
Local cFilOri	:= cFilAnt
Local nX		:= 0
Local nZ		:= 0
Local nMoedas	:= 0
Local aMoedas	:= {}
Local nFator    := 0
Local cNatureza := ""
Local lGestCorp	:= .F.

Default cSaldo		:= '1'
DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'
DEFAULT lImpEnt		:= .F.

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return .F.
Endif

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
	cChave		:= "EMPRESA+UNIDADE+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA+CCUSTO+ITEM+CLVL"
Else
	cChave		:= "EMPRESA+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA+CCUSTO+ITEM+CLVL"
EndIf
	
//Array de Moedas
nMoedas	:= CtbMoedas()

If Empty(cMoedaDe)
	cMoedaDe := '01'
EndIf

For nX := 1 to nMoedas
	cMoeda := StrZero(nX,2)
	If cMoeda >= cMoedaDe .And. cMoeda <= cMoedaAte 
		aAdd(aMoedas,cMoeda)
	EndIf
Next nX

//Cria Tabela Temporแria
If lGestCorp
	AADD(aStruSQL,{"EMPRESA"  ,"C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"UNIDADE"  ,"C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"FILIAL"   ,"C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"EMPRESA"  ,"C",Len(SM0->M0_CODIGO),00})
	AADD(aStruSQL,{"UNIDADE"  ,"C",02,00})	
	AADD(aStruSQL,{"FILIAL"   ,"C",TamSx3("CT1_FILIAL")[1],00})
EndIf
AADD(aStruSQL,{"DATAMOV"  ,"D",08,00})
AADD(aStruSQL,{"MOEDA"    ,"C",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"CONTA"    ,"C",TamSx3("CT1_CONTA")[1],00})
AADD(aStruSQL,{"CCUSTO"   ,"C",TamSx3("CTT_CUSTO")[1],00})
AADD(aStruSQL,{"ITEM"     ,"C",TamSx3("CTD_ITEM")[1],00})
AADD(aStruSQL,{"CLVL"     ,"C",TamSx3("CTH_CLVL")[1],00})
AADD(aStruSQL,{"DESCRICAO","C",TamSx3("CT1_DESC01")[1],00})
AADD(aStruSQL,{"SALDOATU" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOACM" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDODEB" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOCRD" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOATU2","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOANT" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"MOVIMENTO","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})

If Select(cAliasTRB) > 0
	(cAliasTRB)->(dbCloseArea())
EndIf

MsErase(cAliasTRB)
MsCreate(cAliasTRB, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasTRB, cAliasTRB, .T., .F. )
//Cria o Indice
IndRegua(cAliasTRB,cAliasTRB,cChave,,)

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf

	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	For nZ := 1 To Len(aMoedas)
		cAlsDados := GetCntSld( cAnoMes, aMoedas[nZ], aMoedas[nZ] , , cSaldo , , , .T., .T., .F., .T.,,lImpEnt)
		
		DbSelectArea(cAlsDados)
		DbGoTop()
		While (cAlsDados)-> (!Eof())
			nSaldoAtual := (cAlsDados)->SALDODEB - (cAlsDados)->SALDOCRD // D้bito - Cr้dito //aRegs[nX][3] - aRegs[nX][4] // Debito - Credito
			nSaldoACM   := (cAlsDados)->SALDOACM // Saldo Acumulado //aRegs[nX][5]
			nFator		:= 1
            
			cNatureza := CtbxSPNvl((cAlsDados)->CONTA,"CT1_NORMAL")
			
			If cNatureza == '1' // Conta Natureza Devedora 
				nSaldoAtual :=	nSaldoAtual
				nSaldoACM   := -1 * (nSaldoACM)
				nFator		:= -1
			EndIf
			
			If cNatureza == '2' // Conta Natureza Credora
				nSaldoAtual :=	-1 * nSaldoAtual
				nSaldoACM   := (nSaldoACM)	
			EndIf

			If (cAliasTRB)->(MsSeek(cEmpAnt + cFilAnt + DToS((cAlsDados)->DATAMOV) + aMoedas[nZ] + (cAlsDados)->CONTA + (cAlsDados)->CCUSTO + (cAlsDados)->ITEM + (cAlsDados)->CLVL ))
				RecLock(cAliasTRB,.F.)
				(cAliasTRB)->SALDOATU 	+= nSaldoAtual 
				(cAliasTRB)->SALDOACM 	+= nSaldoACM
				(cAliasTRB)->SALDOANT  	+= nFator * (cAlsDados)->SALDOANT // Saldo Anterior 	//aRegs[nX][10]
				(cAliasTRB)->SALDODEB  	+= nFator * (cAlsDados)->SALDODEB // Saldo a D้bito 	//aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  	+= nFator * (cAlsDados)->SALDOCRD // Saldo a Cr้dito 	//aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 	+= nFator * (cAlsDados)->SALDOACM // Saldo Acumulado 	//aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO 	+= nFator * (cAlsDados)->MOVIMENTO// Movimento 			//aRegs[nX][11]
				(cAliasTRB)->(MsUnlock())        
			Else
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->EMPRESA 	:= (cAlsDados)->EMPRESA 	// Empresa 				//cEmpAnt
				(cAliasTRB)->UNIDADE  	:= (cAlsDados)->UNIDADE		// Filial 				//cFilAnt
				(cAliasTRB)->FILIAL  	:= (cAlsDados)->FILIAL		// Filial 				//cFilAnt
				(cAliasTRB)->DATAMOV 	:= (cAlsDados)->DATAMOV		// Data do Movimento 	//aRegs[nX][1]
				(cAliasTRB)->MOEDA   	:= aMoedas[nZ]
				(cAliasTRB)->CONTA   	:= (cAlsDados)->CONTA		// Conta Contแbil		//aRegs[nX][2]
				(cAliasTRB)->CCUSTO  	:= (cAlsDados)->CCUSTO		// Centro de Custo		//aRegs[nX][12]
				(cAliasTRB)->ITEM    	:= (cAlsDados)->ITEM		// Item Contแbil		//aRegs[nX][13]
				(cAliasTRB)->CLVL    	:= (cAlsDados)->CLVL		// Classe de Valor		//aRegs[nX][14]
				(cAliasTRB)->DESCRICAO	:= (cAlsDados)->DESCRICAO	// Descri็ใo da Conta Contแbil //aRegs[nX][6]
				(cAliasTRB)->SALDOATU 	:= nSaldoAtual 
				(cAliasTRB)->SALDOACM 	:= nSaldoACM
				(cAliasTRB)->SALDOANT  	:= nFator * (cAlsDados)->SALDOANT	// Saldo Anterior 	//aRegs[nX][10]
				(cAliasTRB)->SALDODEB  	:= nFator * (cAlsDados)->SALDODEB	// Saldo a D้bito 	//aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  	:= nFator * (cAlsDados)->SALDOCRD	// Saldo a Cr้dito	//aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 	:= nFator * (cAlsDados)->SALDOACM	// Saldo Acumulado	//aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO 	:= nFator * (cAlsDados)->MOVIMENTO	// Movimento		//aRegs[nX][11]
				(cAliasTRB)->(MsUnlock())
			EndIf
			(cAlsDados)->(DbSkip())
		EndDo
		(cAlsDados)->(DbCloseArea())
	Next nZ	
Next nContFil

cFilAnt := cFilOri

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCntSld  บAutor  ณAlvaro Camillo Netoบ Data ณ 03/02/11    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o saldo do plano de contas de varios perํodos       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetCntSld(	cAnoMes, cMoeda, cMoedaDesc, lConsSaldo, cSaldos,	cHeader,;
					dDataLP, lVlrZerado, lMovPeriodo, lPlGerSint, lNImpMov, lImpAntLP, lImpEnt)

Local nTmArray   	:= 00
Local aCTSArea   	:= {}
Local aSetOfBook 	:= CtbSetOf("001")
Local dDtIni
Local dDtFim
Local lGestCorp		:= .F.
Local aAreaCT1		:= {}
Local aAreaCTT		:= {}
Local aAreaCTD		:= {}
Local aAreaCTH		:= {}
Local cAliasTRB		:= GetNextAlias()
Local aStruSQL		:= {}
Local cChave		:= ""
Local nSldDeb		:= 0
Local nSldCrd		:= 0
Local nSldAcm		:= 0
Local nSldAntDeb	:= 0
Local nSldAntCrd	:= 0
Local nSldAntAcm	:= 0
Local cFilCT1		:= XFILIAL("CT1")
Local cFilCTT		:= XFILIAL("CTT")
Local cFilCTD		:= XFILIAL("CTD")
Local cFilCTH		:= XFILIAL("CTH")
Local cEmpCT		:= ""
Local cUndCT		:= ""
Local cFilCT		:= ""
Local nCTMov		:= 0 // Saldo da Conta Contแbil
Local nCCMov		:= 0 // Saldo do Centro de Custo
Local nITMov		:= 0 // Saldo do Item Contแbil
Local nCLMov		:= 0 // Saldo da Classe de Valor
Local nCTDeb		:= 0 // Saldo a D้bito da Conta 
Local nCCDeb		:= 0 // Saldo a D้bito do Centro de Custo
Local nITDeb		:= 0 // Saldo a D้bito do Item Contแbil
Local nCLDeb		:= 0 // Saldo a D้bito da Classe de Valor
Local nCTCrd		:= 0 // Saldo a Cr้dito da Conta Contabil
Local nCCCrd		:= 0 // Saldo a Cr้dito do Centro de Custo
Local nITCrd		:= 0 // Saldo a Cr้dito do Item Contแbil
Local nCLCrd		:= 0 // Saldo a Cr้dito da Classe de Valor
Local nCTAcm		:= 0 // Saldo Acumulado da Conta Contabil
Local nCCAcm		:= 0 // Saldo Acumulado do Centro de Custo
Local nITAcm		:= 0 // Saldo Acumulado do Item Contแbil
Local nCLAcm		:= 0 // Saldo Acumulado da Classe de Valor
Local nCTAnt		:= 0 // Saldo Anterior da Conta Contabil
Local nCCAnt		:= 0 // Saldo Anterior do Centro de Custo
Local nITAnt		:= 0 // Saldo Anterior do Item Contแbil
Local nCLAnt		:= 0 // Saldo Anterior da Classe de Valor
Local nCCTMov		:= 0 // Valor Total de Movimentos de Centros de Custos de uma Conta Contแbil
Local nCCTDeb		:= 0 // Saldo Total a D้bito dos Centros de Custos de uma Conta Contแbil
Local nCCTCrd		:= 0 // Saldo Total a Cr้dito dos Centros de Custos de uma Conta Contแbil
Local nCCTAcm		:= 0 // Saldo Total Acumulado dos Centros de Custos de uma Conta Contแbil
Local nCCTAnt		:= 0 // Saldo Total Anterior dos Centros de Custos de uma Conta Contแbil
Local nITTMov		:= 0 // Valor Total de Movimentos de Itens Contab้is de um Centro de Custo
Local nITTDeb		:= 0 // Saldo Total a D้bito de Itens Contab้is de um Centro de Custo
Local nITTCrd		:= 0 // Saldo Total a Cr้dito de Itens Contab้is de um Centro de Custo
Local nITTAcm		:= 0 // Saldo Total Acumulado de Itens Contab้is de um Centro de Custo
Local nITTAnt		:= 0 // Saldo Total Anterior de Itens Contab้is de um Centro de Custo
Local nCLTMov		:= 0 // Valor Total de Movimentos de classes de valor de um Item Contabil
Local nCLTDeb		:= 0 // Saldo Total a D้bito de classes de valor de um Item Contabil
Local nCLTCrd		:= 0 // Saldo Total a Cr้dito de classes de valor de um Item Contabil
Local nCLTAcm		:= 0 // Saldo Total Acumulado de classes de valor de um Item Contabil
Local nCLTAnt		:= 0 // Saldo Total Anterior de classes de valor de um Item Contabil 

Default cMoeda      := '01'
Default cMoedaDesc  := '01'
Default lConsSaldo  := .F.
Default cSaldos     := '1'
Default cHeader     := ''
Default dDataLP     := Nil
Default lVlrZerado  := .T.
Default lMovPeriodo := .F.
Default lPlGerSint  := .T.
Default lNImpMov    := .T.
Default lImpAntLP   := .F.
Default lImpEnt		:= .F.

dDtIni := STOD(cAnoMes+'01')
dDtFim := LastDay(dDtIni)

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
	cChave		:= "EMPRESA+UNIDADE+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA+CCUSTO+ITEM+CLVL"
Else
	cChave		:= "EMPRESA+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA+CCUSTO+ITEM+CLVL"
EndIf

If Select(cAliasTRB) > 0
	(cAliasTRB)->(dbCloseArea())
EndIf

//Cria Tabela Temporแria
If lGestCorp
	AADD(aStruSQL,{"EMPRESA"  ,"C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"UNIDADE"  ,"C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"FILIAL"   ,"C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"EMPRESA"  ,"C",Len(SM0->M0_CODIGO),00})
	AADD(aStruSQL,{"UNIDADE"  ,"C",02,00})	
	AADD(aStruSQL,{"FILIAL"   ,"C",TamSx3("CT1_FILIAL")[1],00})
EndIf

AADD(aStruSQL,{"DATAMOV"  	,"D",08,00})
AADD(aStruSQL,{"MOEDA"   	,"C",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"CONTA"    	,"C",TamSx3("CT1_CONTA")[1],00})
AADD(aStruSQL,{"CCUSTO"  	,"C",TamSx3("CTT_CUSTO")[1],00})
AADD(aStruSQL,{"ITEM"    	,"C",TamSx3("CTD_ITEM")[1],00})
AADD(aStruSQL,{"CLVL"     	,"C",TamSx3("CTH_CLVL")[1],00})
AADD(aStruSQL,{"DESCRICAO"	,"C",TamSx3("CT1_DESC01")[1],00})
AADD(aStruSQL,{"NORMAL"		,"C",TamSx3("CT1_NORMAL")[1],00})
AADD(aStruSQL,{"SALDOACM"	,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDODEB"	,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOCRD"	,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOANT"	,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"MOVIMENTO"	,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})

MsErase(cAliasTRB)
MsCreate(cAliasTRB, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cAliasTRB, cAliasTRB, .T., .F. )

//Cria o Indice
IndRegua(cAliasTRB,cAliasTRB,cChave,,)

//------------------------------------------------------------//
// Localiza o maior codigo da visใo gerencial em questใo      //
//------------------------------------------------------------//
aCTSArea := CTS->(GetArea())
CTS->(DbSetOrder(2))
CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]+Replicate("Z",TamSx3("CTS_CONTAG")[1]),.T.))
If CTS->CTS_CODPLA != "001"
	CTS->(DbSkip(-1))
EndIf
nTmArray := Val(CTS->CTS_CONTAG)
CTS->(RestArea(aCTSArea))

DbSelectArea( "CT1" )
CT1->( DbSetOrder( 1 ) )
aAreaCT1 := CT1->(GetArea())

DbSelectArea( "CTT" )
CTT->( DbSetOrder( 1 ) )
aAreaCTT := CTT->(GetArea())

DbSelectArea( "CTD" )
CTD->( DbSetOrder( 1 ) )
aAreaCTD := CTD->(GetArea())

DbSelectArea( "CTH" )
CTH->( DbSetOrder( 1 ) )
aAreaCTH := CTH->(GetArea())

//------------------------------------------------------------//
// Carrega array conforme parametros e exclui arrays em branco//
//------------------------------------------------------------//
DbSelectArea( "CT1" )
CT1->( DbSetOrder( 1 ) )
CT1->( DbGoTop() )
Do While CT1->( !Eof() ) .AND. CT1->CT1_FILIAL == cFilCT1
	If !lPlGerSint .And. CT1->CT1_CLASSE=='1'
		CT1->( DbSkip() )
		Loop
	EndIf
	
	AutoGrLog("<<<<<INICIO DO PROCESSAMENTO DA CONTA " + CT1->CT1_CONTA + ": " + CT1->CT1_DESC01 + " E AS DEMAIS ENTIDADES CONTABEIS.>>>>> " - Time())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retorno:                                           ณ
	//ณ [1] Movimento Devedor 	                           ณ
	//ณ [2] Movimento Credor		                       ณ
	//ณ [3] Movimento do Mes		                       ณ
	//ณ [4] Saldo Final                                	   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nSldDeb		:= MovConta(CT1->CT1_CONTA,dDtIni,dDtFim,cMoeda,cSaldos,1,1,,dDataLP)
	nSldCrd		:= MovConta(CT1->CT1_CONTA,dDtIni,dDtFim,cMoeda,cSaldos,2,1,,dDataLP)
	nSldAcm		:= MovConta(CT1->CT1_CONTA,dDtIni,dDtFim,cMoeda,cSaldos,4,1,,dDataLP)
	nSldAntDeb	:= MovConta(CT1->CT1_CONTA,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,1,1,,dDataLP)
	nSldAntCrd	:= MovConta(CT1->CT1_CONTA,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,2,1,,dDataLP)
	nSldAntAcm	:= MovConta(CT1->CT1_CONTA,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,4,1,,dDataLP)
		
	/*
	 * Armazenamento dos saldos individual por Conta Contabil
	 */
	nCTMov := nSldCrd - nSldAntCrd + nSldAntDeb -  nSldDeb // MovConta(CT1->CT1_CONTA,dDtIni,dDtFim,cMoeda,cSaldos,3,1,,dDataLP)  
	nCTDeb := nSldDeb - nSldAntDeb
	nCTCrd := nSldCrd - nSldAntCrd
	nCTAcm := nSldAcm
	nCTAnt := nSldAntAcm
	
	If lImpEnt
		/*
		 * Armazenamento de saldos totais de centros de custos de uma conta contแbil
		 */
		nCCTMov := 0
		nCCTDeb := 0
		nCCTCrd := 0
		nCCTAcm := 0
		nCCTAnt := 0
		/*
		 * Leitura do Cadastro de Centro de Custo
		 */
		CTT->( DbGoTop() )
		Do While !CTT->(Eof()) .And. CTT->CTT_FILIAL == cFilCTT
			If !lPlGerSint .And. CTT->CTT_CLASSE=='1'
				CTT->( DbSkip() )
				Loop
			EndIf
			/*
			 * Busca de saldos do Centro do Custo para o Perํodo Informado
			 */
			 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Retorno:                                          ณ
			//ณ [1] Movimento Devedor 	                           ณ
			//ณ [2] Movimento Credor		                        ณ
			//ณ [3] Movimento do Mes		                        ณ
			//ณ [4] Saldo Final                                	ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nSldDeb		:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,dDtIni,dDtFim,cMoeda,cSaldos,1)
			nSldCrd		:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,dDtIni,dDtFim,cMoeda,cSaldos,2)
			nSldAcm		:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,dDtIni,dDtFim,cMoeda,cSaldos,4)
			nSldAntDeb	:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,1)
			nSldAntCrd	:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,2)
			nSldAntAcm	:= MovCusto(CT1->CT1_CONTA,CTT->CTT_CUSTO,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,4)
			
			/*
			 * Armazenamento dos saldos individual por centro de custo 
			 */
			nCCMov := nSldCrd - nSldAntCrd + nSldAntDeb -  nSldDeb
			nCCDeb := nSldDeb - nSldAntDeb
			nCCCrd := nSldCrd - nSldAntCrd
			nCCAcm := nSldAcm
			nCCAnt := nSldAntAcm
	
			/*
			 * Armazenamento de saldos totais de itens contab้is de um centro de custo
			 */
			nITTMov := 0
			nITTDeb := 0
			nITTCrd := 0
			nITTAcm := 0
			nITTAnt := 0
			
			/*
			 * Leitura do Cadastro de Item Contabil
			 */
			CTD->( DbGoTop() )
			Do While !CTD->(Eof()) .And. CTD->CTD_FILIAL == cFilCTD
				If !lPlGerSint .And. CTD->CTD_CLASSE=='1'
					CTD->( DbSkip() )
					Loop
				EndIf
				nSldDeb		:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,dDtIni,dDtFim,cMoeda,cSaldos,1)
				nSldCrd		:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,dDtIni,dDtFim,cMoeda,cSaldos,2)
				nSldAcm		:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,dDtIni,dDtFim,cMoeda,cSaldos,4)
				nSldAntDeb	:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,1)
				nSldAntCrd	:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,2)
				nSldAntAcm	:= MovItem(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,4)
				
				/*
				 * Armazenamento dos saldos individual por Item Contแbil
				 */
				nITCont:= CTD->CTD_ITEM
				nITMov := nSldCrd - nSldAntCrd + nSldAntDeb -  nSldDeb
				nITDeb := nSldDeb - nSldAntDeb
				nITCrd := nSldCrd - nSldAntCrd
				nITAcm := nSldAcm
				nITAnt := nSldAntAcm
				
				/*
				 * Armazenamento de saldos totais de itens contab้is de um centro de custo
				 */
				nITTMov += nITMov
				nITTDeb += nITDeb
				nITTCrd += nITCrd
				nITTAcm += nITAcm
				nITTAnt += nITAnt
				
				/*
				 * Armazenamento de saldos totais de classes de valor de um item contแbil
				 */
				nCLTMov := 0
				nCLTDeb := 0
				nCLTCrd := 0
				nCLTAcm := 0
				nCLTAnt := 0				
				CTH->( DbGoTop() )
				Do While !CTH->(Eof()) .And. CTH->CTH_FILIAL == cFilCTH
					If !lPlGerSint .And. CTH->CTH_CLASSE=='1'
						CTH->( DbSkip() )
						Loop
					EndIf
					nSldDeb		:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,dDtIni,dDtFim,cMoeda,cSaldos,1)
					nSldCrd		:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,dDtIni,dDtFim,cMoeda,cSaldos,2)
					nSldAcm		:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,dDtIni,dDtFim,cMoeda,cSaldos,4)
					nSldAntDeb	:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,1)
					nSldAntCrd	:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,2)
					nSldAntAcm	:= MovClass(CT1->CT1_CONTA,CTT->CTT_CUSTO,CTD->CTD_ITEM,CTH->CTH_CLVL,FirstDay(dDtIni-1),dDtIni-1,cMoeda,cSaldos,4)
					
					/*
					 * Armazenamento dos saldos individual por Classe de Valor
					 */
					nCLVL:= CTH->CTH_CLVL
					nCLMov := nSldCrd - nSldAntCrd + nSldAntDeb -  nSldDeb
					nCLDeb := nSldDeb - nSldAntDeb
					nCLCrd := nSldCrd - nSldAntCrd
					nCLAcm := nSldAcm
					nCLAnt := nSldAntAcm
				
					/*
					 * Armazenamento de saldos totais de classes de valor de um item contแbil
					 */
					nCLTMov += nCLMov
					nCLTDeb += nCLDeb
					nCLTCrd += nCLCrd
					nCLTAcm += nCLAcm
					nCLTAnt += nCLAnt
					
					/*
					 * Cria็ใo do Saldo do Item Contabil Consolidado ( Sem Saldo da Classe de Valor )
					 */
					If !(cAliasTRB)->(DbSeek(cEmpCT + cUndCT + cFilCT + CT1->CT1_CONTA + CTT->CTT_CUSTO + CTD->CTD_ITEM + CTH->CTH_CLVL))
						(cAliasTRB)->(RecLock(cAliasTRB,.T.))
						If lGestCorp .AND. FindFunction("FWCompany")
							(cAliasTRB)->EMPRESA := FWCompany()
						Else
							(cAliasTRB)->EMPRESA := SM0->M0_CODIGO
						EndIf
						
						If lGestCorp .AND. FindFunction("FWUnitBusiness")
							(cAliasTRB)->UNIDADE := FWUnitBusiness()
						Else
							(cAliasTRB)->UNIDADE := ""
						EndIf
						
						If lGestCorp .AND. FindFunction("FWCodFil")
							(cAliasTRB)->FILIAL := FWCodFil()
						Else
							(cAliasTRB)->FILIAL := XFILIAL()
						EndIf

						(cAliasTRB)->DATAMOV	:= dDtFim  						// Data do Movimento
						(cAliasTRB)->CONTA		:= CT1->CT1_CONTA				// Conta Contแbil
						(cAliasTRB)->SALDODEB	:= nCLDeb 						// Saldo a D้bito
						(cAliasTRB)->SALDOCRD	:= nCLCrd						// Saldo a Cr้dito
						(cAliasTRB)->SALDOACM	:= nCLAcm						// Saldo Acumulado
						(cAliasTRB)->DESCRICAO	:= CT1->CT1_DESC01				// Descri็ใo da Conta Contแbil
						(cAliasTRB)->NORMAL		:= CT1->CT1_NORMAL				// Condi็ใo Normal da Conta Contแbil (Devedora/Credora)
						(cAliasTRB)->SALDOANT	:= nCLAnt						// Saldo Anterior
						(cAliasTRB)->MOVIMENTO	:= nCLMov						// Movimento
						(cAliasTRB)->CCUSTO		:= CTT->CTT_CUSTO				// Centro de Custo
						(cAliasTRB)->ITEM 		:= CTD->CTD_ITEM				// Item Contแbil
						(cAliasTRB)->CLVL		:= CTH->CTH_CLVL				// Classe de Valor
						(cAliasTRB)->(MsUnLock())
						AutoGrLog("----------------------------------------------------------------------------------------")		
						AutoGrLog("Empresa.................... " + (cAliasTRB)->EMPRESA + " -> " + FwCompanyName((cAliasTRB)->EMPRESA) + " " + Time())
						AutoGrLog("Unidade de Neg๓cio......... " + (cAliasTRB)->UNIDADE + " -> " + FwUnitName((cAliasTRB)->UNIDADE) + " " + Time())		
						AutoGrLog("Filial..................... " + (cAliasTRB)->FILIAL + " -> " + FwFilName((cAliasTRB)->EMPRESA,(cAliasTRB)->FILIAL) + " " + Time())
						AutoGrLog("Conta Contแbil............. " + CT1->CT1_CONTA + " -> " + CT1->CT1_DESC01 + " - " + Time() )
						AutoGrLog("Centro de Custo............ " + CTT->CTT_CUSTO + " -> " + CTT->CTT_DESC01 + " - " + Time() )
						AutoGrLog("Item Contแbil.............. " + CTD->CTD_ITEM + " -> " + CTD->CTD_DESC01 + " - " + Time() )
						AutoGrLog("Classe de Valor............ " + CTH->CTH_CLVL + " -> " + CTH->CTH_DESC01 + " - " + Time() )
						AutoGrLog("Saldo a D้bito............. " + TRANSFORM((cAliasTRB)->SALDODEB,"@E 999,999,999.999") + " " + Time())
						AutoGrLog("Saldo a Cr้dito............ " + TRANSFORM((cAliasTRB)->SALDOCRD,"@E 999,999,999.999") + " " + Time())
						AutoGrLog("Saldo Acumulado............ " + TRANSFORM((cAliasTRB)->SALDOACM,"@E 999,999,999.999") + " " + Time())
						AutoGrLog("Condi็ใo Normal............ " + Iif((cAliasTRB)->NORMAL == "1","Devedora","Credora") + " " + Time())
						AutoGrLog("Saldo Anterior............. " + TRANSFORM((cAliasTRB)->SALDOANT,"@E 999,999,999.999") + " " + Time())
						AutoGrLog("Movimento/Saldo Atual...... " + TRANSFORM((cAliasTRB)->MOVIMENTO,"@E 999,999,999.999") + " " + Time())		
						AutoGrLog("----------------------------------------------------------------------------------------")
					EndIf
					CTH->( DbSkip() )
				EndDo
				/*
				 * Cria็ใo do Saldo do Item Contabil Consolidado ( Sem Saldo da Classe de Valor )
				 */
				If !(cAliasTRB)->(DbSeek(cEmpCT + cUndCT + cFilCT + CT1->CT1_CONTA + CTT->CTT_CUSTO + CTD->CTD_ITEM + Space(TamSx3("CTH_CLVL")[1])))
					(cAliasTRB)->(RecLock(cAliasTRB,.T.))
					If lGestCorp .AND. FindFunction("FWCompany")
						(cAliasTRB)->EMPRESA := FWCompany()
					Else
						(cAliasTRB)->EMPRESA := SM0->M0_CODIGO
					EndIf
					
					If lGestCorp .AND. FindFunction("FWUnitBusiness")
						(cAliasTRB)->UNIDADE := FWUnitBusiness()
					Else
						(cAliasTRB)->UNIDADE := ""
					EndIf
					
					If lGestCorp .AND. FindFunction("FWCodFil")
						(cAliasTRB)->FILIAL := FWCodFil()
					Else
						(cAliasTRB)->FILIAL := XFILIAL()
					EndIf

					(cAliasTRB)->DATAMOV	:= dDtFim  						// Data do Movimento
					(cAliasTRB)->CONTA		:= CT1->CT1_CONTA				// Conta Contแbil
					(cAliasTRB)->SALDODEB	:= nITDeb - nCLTDeb				// Saldo a D้bito
					(cAliasTRB)->SALDOCRD	:= nITCrd - nCLTCrd				// Saldo a Cr้dito
					(cAliasTRB)->SALDOACM	:= nITAcm - nCLTAcm				// Saldo Acumulado
					(cAliasTRB)->DESCRICAO	:= CT1->CT1_DESC01				// Descri็ใo da Conta Contแbil
					(cAliasTRB)->NORMAL		:= CT1->CT1_NORMAL				// Condi็ใo Normal da Conta Contแbil (Devedora/Credora)
					(cAliasTRB)->SALDOANT	:= nITAnt - nCLTAnt				// Saldo Anterior
					(cAliasTRB)->MOVIMENTO	:= nITMov - nCLTMov				// Movimento
					(cAliasTRB)->CCUSTO		:= CTT->CTT_CUSTO				// Centro de Custo
					(cAliasTRB)->ITEM 		:= CTD->CTD_ITEM				// Item Contแbil
					(cAliasTRB)->CLVL		:= Space(TamSx3("CTH_CLVL")[1]) // Classe de Valor
					(cAliasTRB)->(MsUnLock())
					AutoGrLog("----------------------------------------------------------------------------------------")		
					AutoGrLog("Empresa.................... " + (cAliasTRB)->EMPRESA + " -> " + FwCompanyName((cAliasTRB)->EMPRESA) + " " + Time())
					AutoGrLog("Unidade de Neg๓cio......... " + (cAliasTRB)->UNIDADE + " -> " + FwUnitName((cAliasTRB)->UNIDADE) + " " + Time())		
					AutoGrLog("Filial..................... " + (cAliasTRB)->FILIAL + " -> " + FwFilName((cAliasTRB)->EMPRESA,(cAliasTRB)->FILIAL) + " " + Time())
					AutoGrLog("Conta Contแbil............. " + CT1->CT1_CONTA + " -> " + CT1->CT1_DESC01 + " - " + Time() )
					AutoGrLog("Centro de Custo............ " + CTT->CTT_CUSTO + " -> " + CTT->CTT_DESC01 + " - " + Time() )
					AutoGrLog("Item Contแbil.............. " + CTD->CTD_ITEM + " -> " + CTD->CTD_DESC01 + " - " + Time() )
					AutoGrLog("Classe de Valor............ N/A - " + Time() )
					AutoGrLog("Saldo a D้bito............. " + TRANSFORM((cAliasTRB)->SALDODEB,"@E 999,999,999.999") + " " + Time())
					AutoGrLog("Saldo a Cr้dito............ " + TRANSFORM((cAliasTRB)->SALDOCRD,"@E 999,999,999.999") + " " + Time())
					AutoGrLog("Saldo Acumulado............ " + TRANSFORM((cAliasTRB)->SALDOACM,"@E 999,999,999.999") + " " + Time())
					AutoGrLog("Condi็ใo Normal............ " + Iif((cAliasTRB)->NORMAL == "1","Devedora","Credora") + " " + Time())
					AutoGrLog("Saldo Anterior............. " + TRANSFORM((cAliasTRB)->SALDOANT,"@E 999,999,999.999") + " " + Time())
					AutoGrLog("Movimento/Saldo Atual...... " + TRANSFORM((cAliasTRB)->MOVIMENTO,"@E 999,999,999.999") + " " + Time())		
					AutoGrLog("----------------------------------------------------------------------------------------")
				EndIf
				CTD->( DbSkip() )
			EndDo		    
			
			/*
			 * Cria็ใo do Saldo do Centro de Custo Consolidado ( Sem Saldo de Item Contแbil e Sem Saldo da Classe de Valor)
			 */
			If !(cAliasTRB)->(DbSeek(cEmpCT + cUndCT + cFilCT + CT1->CT1_CONTA + CTT->CTT_CUSTO + Space(TamSx3("CTD_ITEM")[1]) + Space(TamSx3("CTH_CLVL")[1])))
				(cAliasTRB)->(RecLock(cAliasTRB,.T.))
				If lGestCorp .AND. FindFunction("FWCompany")
					(cAliasTRB)->EMPRESA := FWCompany()
				Else
					(cAliasTRB)->EMPRESA := SM0->M0_CODIGO
				EndIf
				
				If lGestCorp .AND. FindFunction("FWUnitBusiness")
					(cAliasTRB)->UNIDADE := FWUnitBusiness()
				Else
					(cAliasTRB)->UNIDADE := ""
				EndIf
				
				If lGestCorp .AND. FindFunction("FWCodFil")
					(cAliasTRB)->FILIAL := FWCodFil()
				Else
					(cAliasTRB)->FILIAL := XFILIAL()
				EndIf

				(cAliasTRB)->DATAMOV	:= dDtFim  						// Data do Movimento
				(cAliasTRB)->CONTA		:= CT1->CT1_CONTA				// Conta Contแbil
				(cAliasTRB)->SALDODEB	:= nCCDeb - nITTDeb				// Saldo a D้bito
				(cAliasTRB)->SALDOCRD	:= nCCCrd - nITTCrd				// Saldo a Cr้dito
				(cAliasTRB)->SALDOACM	:= nCCAcm - nITTAcm				// Saldo Acumulado
				(cAliasTRB)->DESCRICAO	:= CT1->CT1_DESC01				// Descri็ใo da Conta Contแbil
				(cAliasTRB)->NORMAL		:= CT1->CT1_NORMAL				// Condi็ใo Normal da Conta Contแbil (Devedora/Credora)
				(cAliasTRB)->SALDOANT	:= nCCAnt - nITTAnt				// Saldo Anterior
				(cAliasTRB)->MOVIMENTO	:= nCCMov - nITTMov				// Movimento
				(cAliasTRB)->CCUSTO		:= CTT->CTT_CUSTO				// Centro de Custo
				(cAliasTRB)->ITEM 		:= Space(TamSx3("CTD_ITEM")[1])	// Item Contแbil
				(cAliasTRB)->CLVL		:= Space(TamSx3("CTH_CLVL")[1]) // Classe de Valor
				(cAliasTRB)->(MsUnLock())
				AutoGrLog("----------------------------------------------------------------------------------------")		
				AutoGrLog("Empresa.................... " + (cAliasTRB)->EMPRESA + " -> " + FwCompanyName((cAliasTRB)->EMPRESA) + " " + Time())
				AutoGrLog("Unidade de Neg๓cio......... " + (cAliasTRB)->UNIDADE + " -> " + FwUnitName((cAliasTRB)->UNIDADE) + " " + Time())		
				AutoGrLog("Filial..................... " + (cAliasTRB)->FILIAL + " -> " + FwFilName((cAliasTRB)->EMPRESA,(cAliasTRB)->FILIAL) + " " + Time())
				AutoGrLog("Conta Contแbil............. " + CT1->CT1_CONTA + " -> " + CT1->CT1_DESC01 + " - " + Time() )
				AutoGrLog("Centro de Custo............ N/A - " + Time() )
				AutoGrLog("Item Contแbil.............. N/A - " + Time() )
				AutoGrLog("Classe de Valor............ N/A - " + Time() )
				AutoGrLog("Saldo a D้bito............. " + TRANSFORM((cAliasTRB)->SALDODEB,"@E 999,999,999.999") + " " + Time())
				AutoGrLog("Saldo a Cr้dito............ " + TRANSFORM((cAliasTRB)->SALDOCRD,"@E 999,999,999.999") + " " + Time())
				AutoGrLog("Saldo Acumulado............ " + TRANSFORM((cAliasTRB)->SALDOACM,"@E 999,999,999.999") + " " + Time())
				AutoGrLog("Condi็ใo Normal............ " + Iif((cAliasTRB)->NORMAL == "1","Devedora","Credora") + " " + Time())
				AutoGrLog("Saldo Anterior............. " + TRANSFORM((cAliasTRB)->SALDOANT,"@E 999,999,999.999") + " " + Time())
				AutoGrLog("Movimento/Saldo Atual...... " + TRANSFORM((cAliasTRB)->MOVIMENTO,"@E 999,999,999.999") + " " + Time())		
				AutoGrLog("----------------------------------------------------------------------------------------")
			EndIf			
			CTT->(DbSkip())
		EndDo
	EndIf
	
	/*
	 * Consolida็ใo do Saldo da Conta Contแbil
	 */
	If !(cAliasTRB)->(DbSeek(cEmpCT + cUndCT + cFilCT + CT1->CT1_CONTA + Space(TamSx3("CTT_CUSTO")[1]) + Space(TamSx3("CTD_ITEM")[1]) + Space(TamSx3("CTH_CLVL")[1])))
		(cAliasTRB)->(RecLock(cAliasTRB,.T.))
		If lGestCorp .AND. FindFunction("FWCompany")
			(cAliasTRB)->EMPRESA := FWCompany()
		Else
			(cAliasTRB)->EMPRESA := SM0->M0_CODIGO
		EndIf
		cEmpCT := (cAliasTRB)->EMPRESA
				
		If lGestCorp .AND. FindFunction("FWUnitBusiness")
			(cAliasTRB)->UNIDADE := FWUnitBusiness()
		Else
			(cAliasTRB)->UNIDADE := ""
		EndIf
		cUndCT := (cAliasTRB)->UNIDADE
				
		If lGestCorp .AND. FindFunction("FWCodFil")
			(cAliasTRB)->FILIAL := FWCodFil()
		Else
			(cAliasTRB)->FILIAL := XFILIAL()
		EndIf
		cFilCT := (cAliasTRB)->FILIAL
		(cAliasTRB)->DATAMOV	:= dDtFim  						// Data do Movimento
		(cAliasTRB)->CONTA		:= CT1->CT1_CONTA				// Conta Contแbil
		(cAliasTRB)->SALDODEB	:= nCTDeb - nCCTDeb				// Saldo a D้bito
		(cAliasTRB)->SALDOCRD	:= nCTCrd - nCCTCrd				// Saldo a Cr้dito
		(cAliasTRB)->SALDOACM	:= nCTAcm - nCCTAcm				// Saldo Acumulado
		(cAliasTRB)->DESCRICAO	:= CT1->CT1_DESC01				// Descri็ใo da Conta Contแbil
		(cAliasTRB)->NORMAL		:= CT1->CT1_NORMAL				// Condi็ใo Normal da Conta Contแbil (Devedora/Credora)
		(cAliasTRB)->SALDOANT	:= nCTAnt - nCCTAnt			// Saldo Anterior
		(cAliasTRB)->MOVIMENTO	:= nCTMov - nCCTMov				// Movimento
		(cAliasTRB)->CCUSTO		:= Space(TamSx3("CTT_CUSTO")[1])// Centro de Custo
		(cAliasTRB)->ITEM 		:= Space(TamSx3("CTD_ITEM")[1])	// Item Contแbil
		(cAliasTRB)->CLVL		:= Space(TamSx3("CTH_CLVL")[1]) // Classe de Valor
		(cAliasTRB)->(MsUnLock())
		AutoGrLog("----------------------------------------------------------------------------------------")		
		AutoGrLog("Empresa.................... " + (cAliasTRB)->EMPRESA + " -> " + FwCompanyName((cAliasTRB)->EMPRESA) + " " + Time())
		AutoGrLog("Unidade de Neg๓cio......... " + (cAliasTRB)->UNIDADE + " -> " + FwUnitName((cAliasTRB)->UNIDADE) + " " + Time())		
		AutoGrLog("Filial..................... " + (cAliasTRB)->FILIAL + " -> " + FwFilName((cAliasTRB)->EMPRESA,(cAliasTRB)->FILIAL) + " " + Time())
		AutoGrLog("Conta Contแbil............. " + CT1->CT1_CONTA + " -> " + CT1->CT1_DESC01 + " - " + Time() )
		AutoGrLog("Centro de Custo............ N/A - " + Time() )
		AutoGrLog("Item Contแbil.............. N/A - " + Time() )
		AutoGrLog("Classe de Valor............ N/A - " + Time() )
		AutoGrLog("Saldo a D้bito............. " + TRANSFORM((cAliasTRB)->SALDODEB,"@E 999,999,999.999") + " " + Time())
		AutoGrLog("Saldo a Cr้dito............ " + TRANSFORM((cAliasTRB)->SALDOCRD,"@E 999,999,999.999") + " " + Time())
		AutoGrLog("Saldo Acumulado............ " + TRANSFORM((cAliasTRB)->SALDOACM,"@E 999,999,999.999") + " " + Time())
		AutoGrLog("Condi็ใo Normal............ " + Iif((cAliasTRB)->NORMAL == "1","Devedora","Credora") + " " + Time())
		AutoGrLog("Saldo Anterior............. " + TRANSFORM((cAliasTRB)->SALDOANT,"@E 999,999,999.999") + " " + Time())
		AutoGrLog("Movimento/Saldo Atual...... " + TRANSFORM((cAliasTRB)->MOVIMENTO,"@E 999,999,999.999") + " " + Time())		
		AutoGrLog("----------------------------------------------------------------------------------------")		
	EndIf
	
	AutoGrLog("<<<<<FIM DO PROCESSAMENTO DA CONTA " + CT1->CT1_CONTA + ": " + CT1->CT1_DESC01 + " E AS DEMAIS ENTIDADES CONTABEIS.>>>>> - " + Time())
	CT1->( DbSkip() )
EndDo

RestArea(aAreaCT1)
RestArea(aAreaCTT)
RestArea(aAreaCTD)
RestArea(aAreaCTH)
Return(cAliasTRB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtCntIndCบAutor  ณMarcelo Akama        บ Data ณ  03/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado na visใo gerenci บฑฑ
ฑฑบ          ณ al (Contabilidade)                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCntIndC(cAnoMes,cAliasCON,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
Local lRet		:= .T.
Local cAliasTRB := CriaTrab(nil,.F.)
Local aStruSQL	:= {}
Local nCpos		:= 0

DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'
DEFAULT lImpEnt		:= .F.

/*
 * Verifica se o ambiente trabalha com a Gestใo Corporativa
 */
If FindFunction("FWSizeFilial") .AND. FindFunction("FWSM0Layout")
	lGestCorp	:= FWSizeFilial() > 2
EndIf

AutoGrLog("Inํcio da Cria็ใo da Tabela dos Dados Contแbeis --> Tabela HL9 - Saldos Contแbeis Reais - " + Time())

//Cria Tabela Temporแria Contabilidade
aStruSQL := {}
If lGestCorp
	AADD(aStruSQL,{"HL9_EMPRES","C",Len(FWSM0Layout(cEmpAnt,1)),00})
	AADD(aStruSQL,{"HL9_UNDNEG","C",Len(FWSM0Layout(cEmpAnt,2)),00})
	AADD(aStruSQL,{"HL9_FILIAL","C",Len(FWSM0Layout(cEmpAnt,3)),00})
Else
	AADD(aStruSQL,{"HL9_EMPRES","C",02,00})
	AADD(aStruSQL,{"HL9_UNDNEG","C",02,00})
	AADD(aStruSQL,{"HL9_FILIAL","C",TamSx3("CT2_FILIAL")[1],00})
EndIf

AADD(aStruSQL,{"HL9_PLCONT","C",TamSx3("CTS_CODPLA")[1],00})
AADD(aStruSQL,{"HL9_CNTCTB","C",TamSx3("CT2_DEBITO")[1],00})
AADD(aStruSQL,{"HL9_CCUSTO","C",TamSx3("CT2_CCD")[1],00})
AADD(aStruSQL,{"HL9_ITMCTB","C",TamSx3("CT2_ITEMD")[1],00})
AADD(aStruSQL,{"HL9_CLVL"  ,"C",TamSx3("CT2_CLVLDB")[1],00})
AADD(aStruSQL,{"HL9_MOEDA" ,"N",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"HL9_DATA"  ,"D",08,00})
AADD(aStruSQL,{"HL9_VCTBRL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VSDINI","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VDREAL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VCREAL","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})
AADD(aStruSQL,{"HL9_VSDFIN","N",TamSx3("CT2_VALOR")[1],TamSx3("CT2_VALOR")[2]})

For nCpos := 1 To Len(aStruSQL)
	AutoGrLog("Cria็ใo do Campo " + aStruSQL[nCpos][1] + Time())
Next nCpos

AutoGrLog("Finaliza็ใo da Cria็ใo da Tabela dos Dados Contแbeis --> Tabela HL9 - Saldos Contแbeis Reais - " + Time())

If Select(cAliasCON) > 0
	(cAliasCON)->(dbCloseArea())
EndIf

AutoGrLog("Apagando dados da tabela temporแria HL9 - " + Time())
MsErase(cAliasCON)
AutoGrLog("Cria็ใo da tabela temporแria HL9 na base de dados - " + Time())
MsCreate(cAliasCON, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasCON, cAliasCON, .T., .F. )

AutoGrLog("Buscando dados da tabela temporแria HL9 - " + Time())
//Real
If CtCntInd(cAnoMes,'1',cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte,lImpEnt)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	Do While (cAliasTRB)->(!EOF())
		dbSelectArea(cAliasCON)
		RecLock(cAliasCON,.T.)
		(cAliasCON)->HL9_EMPRES := (cAliasTRB)->EMPRESA
		(cAliasCON)->HL9_UNDNEG := (cAliasTRB)->UNIDADE
		(cAliasCON)->HL9_FILIAL := (cAliasTRB)->FILIAL
		(cAliasCON)->HL9_PLCONT := ""//cSetOfBook
		(cAliasCON)->HL9_CNTCTB := (cAliasTRB)->CONTA
		(cAliasCON)->HL9_CCUSTO := (cAliasTRB)->CCUSTO
		(cAliasCON)->HL9_ITMCTB   := (cAliasTRB)->ITEM
		(cAliasCON)->HL9_CLVL   := (cAliasTRB)->CLVL
		(cAliasCON)->HL9_MOEDA  := Val((cAliasTRB)->MOEDA)
		(cAliasCON)->HL9_DATA   := (cAliasTRB)->DATAMOV
		(cAliasCON)->HL9_VCTBRL := (cAliasTRB)->MOVIMENTO
		(cAliasCON)->HL9_VSDINI := (cAliasTRB)->SALDOANT
		(cAliasCON)->HL9_VDREAL := Abs( (cAliasTRB)->SALDODEB )
		(cAliasCON)->HL9_VCREAL := Abs( (cAliasTRB)->SALDOCRD )
		(cAliasCON)->HL9_VSDFIN := (cAliasTRB)->SALDOATU2
		MsUnlock()
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(dbSkip())
	EndDo
	(cAliasTRB)->(dbCloseArea())
	MsErase(cAliasTRB)
Else
	lRet := .F.
EndIf

Return lRet
