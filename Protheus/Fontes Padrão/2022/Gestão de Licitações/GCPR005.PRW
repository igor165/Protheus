#INCLUDE "Protheus.ch"
#INCLUDE "MsOle.ch" 
#INCLUDE "GCPR005.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GCPR005 º Autor ºAutor  ³ Totvs              º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do Despacho			                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GCP - Gestão de Compras Publicas                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GCPR005()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis locais                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aAliasAnt  := GetArea()

Local lRet       := .F.
Local cArquivo   := AllTrim(GETMV('MV_GCPDESP',,"GCP_DESP"))
Local aDadosWord := {}

Private cPerg     := "GCR005"
Private cCodEdt   := ""
Private cNumPro   := ""
Private cAnexo	  := ""

//Caso a chamada seja feita pelo EDITAL
If FunName() == "GCPA002"
	cCodEdt   := CO1->CO1_CODEDT
	cNumPro   := CO1->CO1_NUMPRO
Else
	If Pergunte(cPerg,.T.)
	
		cCodEdt   := MV_PAR01
		cNumPro   := MV_PAR02
	
		DbSelectArea("CO1")
		DbSetOrder(1)
		If !DbSeek(xFilial("CO1")+cCodEdt+cNumPro)
			Help(" ",1,"GCPR05EDT")//"Edital não encontrado"
			Return(.F.)
		EndIf
		
		If CO1->CO1_ETAPA $ 'PE/PR'
			HELP("   ",1,"GCPRELREV",,STR0002 ,1)//"Edital Revogado/Cancelado, não é possível emitir o relatório"
			Return(.F.)
		EndIf
	Else
		RestArea(aAliasAnt)
		Return(.T.)
	EndIf
EndIf
	
cAlias := If(CO1->CO1_MODALI == "LL","SA1","SA2")

AAdd(aDadosWord , {"cCodEdt"    , cCodEdt    		 })
AAdd(aDadosWord , {"cData"	    , dToc(dDataBase)    }) 

cArqDest  := cArquivo+Alltrim(cCodEdt)

MsgRun(STR0001,,{|| cAnexo := GCPGeraArq(cArquivo,cArqDest,aDadosWord) }) //"Gerando Documento ..."             

If !Empty(cAnexo)
	lRet := .T.
EndIf	

RestArea(aAliasAnt)

Return(lRet)