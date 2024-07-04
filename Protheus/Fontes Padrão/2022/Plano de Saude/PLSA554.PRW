#include "PROTHEUS.CH"
#include "FILEIO.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSA554  º Autor ³ TOTVS S/A			    º Data ³ 07/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importação dos procedimentos do SUS para as tabelas BA8 e  º±±
±±º          ³ BR8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA554()
Local cCadastro	:= "Processamento de importação do arquivo de procedimentos do SUS"  
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca		:= 0
Local cRESSUS	:= GetMv("MV_TABSSUS")
Local cArquivo	:= ""

aAdd(aSays,"Esta rotina irá realizar a importação dos procedimentos do SUS de um arquivo CSV.")

aAdd(aButtons, { 5,.T.,{|| cArquivo := SelecArq()}})
aAdd(aButtons, { 1,.T.,{|| nOpca := 1, If( .T.,FechaBatch(),nOpca := 0)}})
aAdd(aButtons, { 2,.T.,{|| nOpca := 0,FechaBatch()}})

FormBatch(cCadastro, aSays, aButtons, , 160)                          

If nOpca == 1
	If !File(cArquivo)
		MsgAlert("Arquivo CSV "+cArquivo+" não localizado","IMPORTAÇÃO DE PROCEDIMENTOS SUS.")
		Return NIL
	Endif    
	If !PL552VPar("MV_TABSSUS/MV_CDTUNEP")
		Return (.F.)
	Endif

	Processa({||PLProcImp(cRESSUS,cArquivo)},cCadastro,"Processando...",.T.)
	
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSA554  º Autor ³ TOTVS S/A			    º Data ³ 07/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importação dos procedimentos do SUS para as tabelas BA8 e  º±±
±±º          ³ BR8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION SelecArq()

Local cFileOpen 	:= ""

cFileOpen := cGetFile("Arquivo csv | *.csv","SELECIONE O ARQUIVO CSV",,,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE)

If !File(cFileOpen)
	MsgAlert("Arquivo CSV "+cFileOpen+" não localizado","IMPORTAÇÃO DE DADOS.")
	RETURN cFileOpen
Endif 

Return cFileOpen


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLProcImp º Autor ³ TOTVS S/A			    º Data ³ 07/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava os procedimentos do SUS para as tabelas BA8 e BR8    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLProcImp(cRESSUS,cCaminho)
Local cQuery	:= ""
Local cAlias	:= ""
Local cTexto	:= ""
Local cMask		:= ""
Local cLinha	:= ""
Local cCODTAB	:= GetMv("MV_CDTUNEP")
Local nItensImp	:= 0
Local lEnd 		:= .T.
Local aRetLn	:= {}
Local nTamBA8	:= TamSX3("BA8_CODPRO")[1]
Local nTamBR8	:= TamSX3("BR8_CODPSA")[1]
Local nTamBD4	:= TamSX3("BD4_CODPRO")[1]

//Abre arquivo
FT_FUSE(cCaminho)

//Posiciona no primeiro registro
FT_FGOTOP()

//Verifica se arquivo tem conteúdo
If FT_FEOF()
	Return
EndIf

//Le arquivo linha a linha
While !FT_FEOF()

   //Carrega uma linha do arquivo
	cLinha := FT_FREADLN()

	aRetLn := StrToArray(cLinha,";")
                
	If Empty(aRetLn) .OR. Empty(aRetLn[1])
		FT_FSKIP()
		Loop   
	Endif

	BEGIN TRANSACTION 
		If EMPTY(cCODTAB)
			DbSelectArea("BF8")
			BF8->(DbSetOrder(2))
			If BF8->(DbSeek(xFilial("BF8")+alltrim(cRESSUS)))
				cCODTAB := alltrim(BF8->BF8_CODINT+BF8->BF8_CODIGO+BF8->BF8_SEGMEN)
			EndIf
		EndIf

		//Tabela Dinamica de Eventos
		DbSelectArea("BA8")
		BA8->(DbSetOrder(1))
		If LEN(aRetLn) >= 1 .AND. ;
			!BA8->( DbSeek( xFilial("BA8")+AllTrim(cCODTAB)+AllTrim(cRESSUS)+(AllTrim(aRetLn[1]) + SPACE(nTamBA8-LEN(aRetLn[1]))) ) ) // BA8_FILIAL+BA8_CODTAB+BA8_CDPADP+BA8_CODPRO
			RecLock("BA8", .T.)
				BA8_FILIAL	:= xFilial("BA8")
				BA8_CDPADP	:= cRESSUS
				BA8_CODPRO	:= AllTrim(aRetLn[1])
				If LEN(aRetLn) >= 2 .AND. !EMPTY(aRetLn[2])
					BA8_DESCRI := AllTrim(aRetLn[2])
				EndIf
				BA8_NIVEL	:= "1"
				BA8_ANASIN	:= "1"
				BA8_CODPAD	:= cRESSUS
				BA8_CODTAB	:= cCODTAB
			BA8->( MsUnlock() )
		Else
	   		RecLock("BA8", .F.)
				BA8_DESCRI	:= IIf(LEN(aRetLn)>=2, AllTrim(aRetLn[2]), "")
				BA8_NIVEL	:= "1"
				BA8_ANASIN	:= "1"
			BA8->( MsUnlock() )
		Endif
      
		//Tabela Padrao
		DbSelectArea("BR8")
		BR8->(DbSetOrder(1))
		If !BR8->( DbSeek( xFilial("BR8")+alltrim(cRESSUS)+(AllTrim(aRetLn[1]) + SPACE(nTamBR8-LEN(aRetLn[1]))) ) )  //	BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
			RecLock("BR8", .T.)
				BR8_FILIAL	:= xFilial("BR8")
				BR8_CODPAD	:= cRESSUS
				BR8_CODPSA	:= AllTrim(aRetLn[1])
				If LEN(aRetLn) >= 2 .AND. !EMPTY(aRetLn[2])
					BR8_DESCRI := AllTrim(aRetLn[2])
				EndIf
				BR8_NIVEL	:= "1"
				BR8_BENUTL	:= "0"
				BR8_ANASIN	:= "1"
				BR8_CARENC	:= 0
				BR8_IDAMIN	:= 0
				BR8_IDAMAX	:= 0
				BR8_PERIOD	:= 0
				BR8_QTD		:= 0
				BR8_UNMENU	:= 0
				BR8_TMPCIR	:= 0
				BR8_QTDLI	:= 0
				BR8_QTMIAU	:= 0
				BR8_QTMAAU	:= 0
				BR8_QTDFAC	:= 0
			BR8->( MsUnlock() )
		Else
			RecLock("BR8", .F.)
				BR8_DESCRI	:= IIf(LEN(aRetLn)>=2, AllTrim(aRetLn[2]), "")
				BR8_NIVEL	:= "1"
				BR8_BENUTL	:= "0"
				BR8_ANASIN	:= "1"
			BR8->( MsUnlock() )
		Endif
      
		//Unidade de Saude
		DbSelectArea("BD4")
		BD4->(DbSetOrder(1))
		If !BD4->( DbSeek( xFilial("BD4") + cCODTAB + cRESSUS + (AllTrim(aRetLn[1])+SPACE(nTamBD4-LEN(aRetLn[1]))) + "REA" ) )//BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)
			
			RecLock("BD4", .T.)
				BD4_FILIAL	:= xFilial("BD4")
				BD4_CODPRO	:= AllTrim(aRetLn[1])
				BD4_CODTAB	:= cCODTAB
				BD4_CDPADP	:= cRESSUS
				BD4_CODIGO	:= "REA"
				BD4_VALREF	:= 1
				BD4_VIGINI	:= dDatabase
			BD4->( MsUnlock() )
		Else
	   		RecLock("BD4", .F.)
				BD4_VALREF	:= 1
			BD4->( MsUnlock() )
		Endif	          
     
		//IncRegua("Processando... " + AllTrim(Str(nItensImp)) )
		//ProcessMessage()

		nItensImp++
	   
	END TRANSACTION
 
	//Proxima linha
	FT_FSKIP()
End

//Finaliza utilização do arquivo
FT_FUSE()
 
cTexto :=  " Finalizou o processamento !!! " +CHR(13)+CHR(10)
cTexto +=  " Foram importados ou atualizados:  " + AllTrim(Str(nItensImp)) + " procedimentos "+CHR(13)+CHR(10)

__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cTexto)

DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15

DEFINE MSDIALOG oDlg TITLE "Importação concluída com sucesso" From 3,0 to 340,417 PIXEL

@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL

oMemo:bRClicked := {||AllwaysTrue()}

oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
ACTIVATE MSDIALOG oDlg CENTER
lEnd := .T. 

Return(lEnd)

