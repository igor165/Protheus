#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA094.CH"
                                

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA094
Tabela de Itens UF - Índice de Participação dos Municípios

@author Mauro A. Goncalves
@since 09/02/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA094()
Local	oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0001) //Tabela de Itens UF - Índice de Participação dos Municípios
oBrw:SetAlias('CLN')
oBrw:SetMenuDef('FISA094')
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 09/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0005 ACTION 'ImporCLN()' 			OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA094'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA094'	OPERATION 4 ACCESS 0	
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA094'	OPERATION 5 ACCESS 0	
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA094'	OPERATION 8 ACCESS 0
	
Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 09/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStru	:=	FWFormStruct(1, 'CLN')
Local oModel 	:=	MPFormModel():New('FISA094')

oModel:AddFields('MODELO', /*cOwner*/, oStru)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 09/02/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel	:=	FWLoadModel('FISA094')
Local	oStru	:=	FWFormStruct(2, 'CLN')
Local	oView 	:=	FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW', oStru, 'MODELO')

oView:EnableTitleView('VIEW', STR0001) //Tabela de Itens UF - Índice de Participação dos Municípios
oView:CreateHorizontalBox('FIELDS', 100)
oView:SetOwnerView('VIEW', 'FIELDS')

If CLN->(FieldPos("CLN_TIPO"))>0
	oStru:SetProperty('CLN_TIPO',MVC_VIEW_COMBOBOX,{'1=Mensal','2=Anual'})	
Endif

Return oView




Static Function XFUNVldUni( cAlias , nOrder , cChave )
Local		cCmp	:= ReadVar()
Local		lOk		:=	.T.

Default	nOrder	:=	1
Default	cChave	:=	&( cCmp )	

lOk := ExistCpo( cAlias , Upper(cChave) , nOrder )

If lOk
	Help( ,,"JAGRAVADO",,, 1, 0 )
EndIf

Return !lOk                                                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImporCLN ³       ³Fiscal                 ³  Data ³09.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importação da Tabela de Itens UF - Índice de Participação   ³±±
±±³          ³dos Municípios                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ImporCLN()

Local bExec
Local oDlg
Local oDlg1
Local oRadio
Local nOpcf		:= 0
Local nRadio		:= 1
Local cFile		:= ""
Local cType		:= ""
Local nBcoHdl		:= 0
Local cUF			:= "  "

DEFINE MSDIALOG oDlg  FROM 94,1 TO 238,340 TITLE OemToAnsi(STR0001) PIXEL 

@ 07,07 TO 52, 165 OF oDlg  PIXEL

@ 14,19 Say OemToAnsi(STR0002)	SIZE 240,7 OF oDlg PIXEL //Informe o Estado referente a Tabela a ser Importada

@ 32, 20 SAY   "Estado: " SIZE 25,8 PIXEL OF oDlg       
@ 30, 40 MSGET cUF PICTURE "@!" VALID ExistCpo("SX5","12"+cUF) F3 "12" SIZE 20,10 F3 PIXEL OF oDlg

DEFINE SBUTTON FROM 55, 105 TYPE 1 ENABLE OF oDlg ACTION(SelTXT(.T.,@cFile) , nOpcf := 1, oDlg:End()) 
DEFINE SBUTTON FROM 55, 138 TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())  

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcf == 1  
	Processa({|| AtuCLN(cFile,cUF)},STR0011)  
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuCLN    ³ Rev.  ³FISCAL                 ³ Data ³09.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tabela de Itens UF - Índice de Participação dos Municípios  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ CFile - Nome do arquivo a ser importado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Lógico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function  AtuCLN(cArqTxt,cUF)
Local bOldError	:= ErrorBlock( {|x| VerErro(x) } ) // muda code-block de erro
Local cDescErro	:= ""   // Variavel para tratamento de erro
Local aCampo		:= {}
Local cCampo		:= "" 
Local cLinha		:= ""
Local cCodigo		:= ""
Local nx			:= 0 
Local nPos			:= 0
Local dDataIni 	:= CTOD("//")
Local dDataFim 	:= CTOD("//")

//Verifica se a tabela CLN existe     
SX3->(dbSetOrder(1)) 
If !SX3->(dbSeek("CLN")) 
	MSGStop(STR0008, STR0001)
	Return .F.
EndIf	

If Empty(cArqTxt) .Or. Empty(cUF) 
	Return .F.
EndIf	

//Processa arquivo
Begin Transaction
	Begin Sequence   
		FT_FUse(cArqTxt)
		FT_FSkip()
		//Analisando o tamanho do registro
		While (!FT_FEof())
			nX := 0
			IncProc("Analisando a Estrutura do Arquivo " + cArqTxt)
			cLinha  := FT_FREADLN() + "|"
			While (nPos := At("|",SubStr(cLinha,1,len(cLinha)))) > 0
				nX++
				cLinha := Substr(cLinha,nPos+1,len(cLinha))
			EndDo
			If nX <> 4
				DisarmTransaction() //Caso tenha ocorrido erro a transaçao sera desfeita
				MSGStop(STR0003,STR0001)	
				Return .F.
			Endif
	   		FT_FSkip()
		Enddo
		//Processando		
	   	FT_FGotop()
		FT_FSkip()
		While (!FT_FEof())
			IncProc("Registro : "+ AllTrim(Str(nX++)) + ' do arquivo '  + cArqTxt)
   			cLinha  := FT_FREADLN() + "|"
			//Montando array com os campos do registro
			aCampo	:= {}		
			While (nPos := At("|",SubStr(cLinha,1,len(cLinha)))) > 0
				cCampo := Substr(cLinha,1,nPos-1)
				AADD(aCampo,AllTrim(cCampo))
				cLinha := Substr(cLinha,nPos+1,len(cLinha))
			EndDo
			//Tratamento das datas
			dDataIni 	:= CTOD("//")
			dDataFim 	:= CTOD("//")
			If Len(aCampo[3])>0
				dDataIni :=	STOD(Substr(aCampo[3],5,4) + Substr(aCampo[3],3,2)+Substr(aCampo[3],1,2)) 
			EndIF
			If Len(aCampo)>3 .And. Len(aCampo[4])>0
				dDataFim :=	STOD(Substr(aCampo[4],5,4) + Substr(aCampo[4],3,2)+Substr(aCampo[4],1,2)) 
			EndIF
			//Grava tabela						
			cCodigo := aCampo[1] + Space(TAMSX3("CLN_CODIPM")[1]-Len(aCampo[1]))
			If !CLN->(dbSeek(xFilial("CLN") + cUF + cCodigo + DTOS(dDataIni)))
				RecLock('CLN',.T.)                             
				CLN->CLN_FILIAL	:= xFilial("CLN")
				CLN->CLN_UF		:= cUF 
				CLN->CLN_CODIPM	:= aCampo[1]
				CLN->CLN_DSCIPM	:= aCampo[2]		
				CLN->CLN_DTINIV	:= dDataIni
				CLN->CLN_DTFIMV	:= dDataFim
				CLN->(MsUnlock())			
			ElseIf !Empty(dDataFim)
				RecLock('CLN',.F.)
				CLN->CLN_DTFIMV	:= dDataFim
				CLN->(MsUnlock())			
			Endif	
	   		FT_FSkip()
		EndDo
		FT_FUse()
		CLN->(DbGotop())	
		MSGINFO(STR0009,STR0001)
		Recover		
		DisarmTransaction() //Caso tenha ocorrido erro a transaçao sera desfeita
		MSGStop(STR0010,STR0001)
		Return .F.
	End Sequence
	ErrorBlock(bOldError)
End Transaction

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VerErro     ³ Autor ³ Fiscal                ³ Data ³ 09/02/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratamento de erro                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerErro(e)
Local cDescErro := ""

IF e:gencode > 0  
	cDescErro := "DESCRIPTION: " + e:DESCRIPTION + Chr(10)+Chr(13)
  	cDescErro += "ERRORSTACK:"	+ Chr(10)+Chr(13)  
  	cDescErro += e:ERRORSTACK
	Alert(Alltrim(cDescErro))
  	Return .F.
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SelTXT³ Autor ³ Fiscal                    ³ Data ³ 09.02.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleção do arquivo                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function SelTXT(lAbre,cArq)
Local cArq1       

DEFAULT lAbre := .T.

cTipo 	:= OemToAnsi("TXT|")+'*.TXT'
cArq1	:= cGetFile(cTipo, OemToAnsi(STR0001), 1,, lAbre, 1+16+32, .T.) 

If  Empty(cArq1)
	cArq := ""
	Return 
Endif

If "."$cArq1
	cArq1 := Substr(cArq1,1,rat(".", cArq1)-1)
Endif

cArq1    := alltrim(cArq1)
cArq     := Alltrim(cArq1+Right(cTipo,4))

Return

