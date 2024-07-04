#INCLUDE "CTBA005.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA005   ³ Autor ³ Acacio Egas           ³ Data ³ 23/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de configuracoes Contabeis.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA005()

Local oDlg,oGDItens
Local cVar		:=""
Local nOpc 		:= 0
Local cAlias	:= "CT0"
Local aColsCT0	:= {}
Local aRecnosCT0:= {}
Local aHeaderCT0
Local nX
Local aCposNo 		:= {"CT0_OBRIGA"} //Ainda não controla obrigatoriedade sera tratado na proxima melhoria
Local aCposVisual 	:= {"CT0_ALIAS","CT0_ETIDA"} //Seram utilizados na proxima melhoria

If  FINDFUNCTION("CtbVerSX2") 
	If !CtbVerSX2("CT0", .T.)  
		Return
	EndIf
EndIf	
If  FINDFUNCTION("CTBA800") 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se sera utilizada a rotina de cubo das entidades contabeis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMv('MV_CTBCUBE',.F.,"0")=="1"
		CTBA800()
		Return
	EndIf
EndIF
aHeaderCT0	:= GetaHeader("CT0",,aCposNo,,aCposVisual)

dbSelectArea(cAlias)
dbSetOrder(1) // CT0_FILIAL+CT0_ID
dbSeek(xFilial(cAlias))
RegToMemory(cAlias, .F.)
//***************
// Monta aCols	*
//***************
Do While !(cAlias)->(Eof()) .And. xFilial(cAlias)==(cAlias)->CT0_FILIAL
	aAdd(aRecnosCT0, (cAlias)->(Recno()) )
	aAdd(aColsCT0,Array(Len(aHeaderCT0) + 1))
	AEval(aHeaderCT0, {|x,y| aColsCT0[Len(aColsCT0)][y] := If(Alltrim(x[2])$"CT0_ALI_WT|CT0_REC_WT".OR. x[10]=="V",NIL, (cAlias)->(FieldGet(FieldPos(x[2]))) ) })
	aColsCT0[Len(aColsCT0),Len(aHeaderCT0) + 1] := .F.
	(cAlias)->(DbSkip())
EndDo

nOpc := 0
DEFINE MSDIALOG oDlg FROM  70,1 TO 270,550 TITLE STR0009 PIXEL  // "Configuraçao de Entidades Contabeis"

oGDItens:= MsNewGetDados():New( 007, 002, 075, 272, GD_UPDATE,,,"+CT0_ITEM",,,,,,,oDlg,aHeaderCT0,aColsCT0)
		
DEFINE SBUTTON FROM 80, 240 TYPE  1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 80, 205 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End()) //edita

ACTIVATE MSDIALOG oDlg Centered

If nOpc == 1

	aColsCT0	:= oGDItens:aCols
		
	For nX :=1 to Len(aColsCT0)
		DbGoTo(aRecnosCT0[nX])
		RecLock("CT0",.F.)
		CT0->CT0_FILIAL	:= xFilial(cAlias)
		aEval(aHeaderCT0, {|x,y| If(x[10]<>"V",CT0->&(x[2]) := aColsCT0[Nx,y],.F.) })
		MsUnLock()
	Next

EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AutoIncCV0ºAutor  ³ Acacio Egas        º Data ³  11/24/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Auto incremento de Entidades Contabeis.                    º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbIncCT0()

Local aEstrut	:= {"CT0_FILIAL","CT0_ID","CT0_DESC","CT0_CONTR","CT0_ALIAS","CT0_ENTIDA","CT0_OBRIGA","CT0_CPOCHV","CT0_CPODSC","CT0_CPOSUP","CT0_GRPSXG","CT0_F3ENTI","CT0_DSCRES"}
Local aIncCT0	:= {} 
Local nX,nY
/*
Campos a ser criado na tabela CT0 - Configuração Entidade Contabil

CT0_CPOCHV C 10 =>Campo Chave 
CT0_CPODSC C 10         Descrição
CT0_CPOSUP C 10         Codigo Entidade Superior
CT0_GRPSXG C 3          Grupo de Campos
CT0_F3ENTI C 5          Consulta Padrao (F3)

Popular os seguintes conteudos para Entidade 01 - Plano de Contas 
CT0_CPOCHV => CT1_CONTA
CT0_CPODSC => CT1_DESC01
CT0_CPOSUP => CT1_CTASUP
CT0_GRPSXG => 003
CT0_F3ENTI => CT1

Popular os seguintes conteudos para Entidade 02 - Centros de Custo
CT0_CPOCHV => CTT_CUSTO
CT0_CPODSC => CTT_DESC01
CT0_CPOSUP => CTT_CCSUP
CT0_GRPSXG => 004
CT0_F3ENTI => CTT

Popular os seguintes conteudos para Entidade 03 - Item Contabil
CT0_CPOCHV => CTD_ITEM
CT0_CPODSC => CTD_DESC01
CT0_CPOSUP => CTD_ITSUP
CT0_GRPSXG => 005
CT0_F3ENTI => CTD

Popular os seguintes conteudos para Entidade 04 - Classe de Valor
CT0_CPOCHV => CTH_CLVL
CT0_CPODSC => CTH_DESC01
CT0_CPOSUP => CTH_CLSUP
CT0_GRPSXG => 006
CT0_F3ENTI => CTH

Popular os seguintes conteudos para Entidade 05 - NIT
CT0_CPOCHV => CV0_CODIGO
CT0_CPODSC => CV0_DESC
CT0_CPOSUP => CV0_ENTSUP
CT0_GRPSXG => 040
CT0_F3ENTI => CV01
*/

aAdd(aIncCT0, {xFilial("CT0"),"01",STR0001 ,"1","CT1",""  ,"1","CT1_CONTA" ,"CT1_DESC01","CT1_CTASUP","003","CT1" ,STR0005} ) //"Plano de Contas"###"Pl. Contas"
aAdd(aIncCT0, {xFilial("CT0"),"02",STR0002 ,"1","CTT",""  ,"2","CTT_CUSTO" ,"CTT_DESC01","CTT_CCSUP" ,"004","CTT" ,STR0006} ) //"Centro de Custo"###"C. Custo"
aAdd(aIncCT0, {xFilial("CT0"),"03",STR0003 ,"1","CTD",""  ,"2","CTD_ITEM"  ,"CTD_DESC01","CTD_ITSUP" ,"005","CTD" ,STR0007} ) //"Item Contábil"###"It. Contáb"
aAdd(aIncCT0, {xFilial("CT0"),"04",STR0004 ,"1","CTH",""  ,"2","CTH_CLVL"  ,"CTH_DESC01","CTH_CLSUP" ,"006","CTH" ,STR0008} ) //"Classe de Valor"###"Cl. Valor"
If cPaisLoc == "COL"
	aAdd(aIncCT0, {xFilial("CT0"),"05","N.I.T.","1","CV0","01","2","CV0_CODIGO","CV0_DESC","CV0_ENTSUP","040","CV0","N.I.T."} )
ElseIf cPaisLoc == "PER"
	aAdd(aIncCT0, {xFilial("CT0"),"05","R.U.C.","1","CV0","01","2","CV0_CODIGO","CV0_DESC","CV0_ENTSUP","040","CV0","R.U.C."} )
ElseIf cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.)
	aAdd(aIncCT0, {xFilial("CT0"),"05","R.C.A.","1","CV0","01","1","CV0_CODIGO","CV0_DESC","CV0_ENTSUP","040","CV0","R.C.A."} )
EndIf

For nX:= 1 to Len(aIncCT0)
	DbSelectArea("CT0")
	DbSetOrder(1)

	If !DbSeek(aIncCT0[nX,1]+aIncCT0[nX,2])
		RecLock("CT0",.T.)
		For nY := 1 to Len(aEstrut)
			If FieldPos(aEstrut[nY]) > 0
				CT0->&(aEstrut[nY])	:= aIncCT0[nX,nY]
			EndIf
		Next

		MsUnLock()
	Else
		RecLock("CT0",.F.)
		For nY := 1 to Len(aEstrut)
			//somente os campos que nao estao preenchidos 
			If FieldPos(aEstrut[nY]) > 0 .And. Empty(FieldGet(FieldPos(aEstrut[nY])))
				CT0->&(aEstrut[nY])	:= aIncCT0[nX,nY]
			EndIf
		Next

		MsUnLock()
	
	EndIf
Next

Return
