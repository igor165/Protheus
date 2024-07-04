#Include "VEICM640.CH"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM640 | Autor ³ Andre Luis Almeida    ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Itens Relacionados VPD                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEICM640()
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)
Private cGrp := space(4)
Private cCod := space(27)
Private cDes := space(50)
Private aIteVPD  := {}
Private cCodProd := ""
Private cCampo36 := ""
/////////////////////////
// FNC - 20103 RAFAEL  //
/////////////////////////

// Cria Filtro do SXB MC1 //
OFIAtuSXB()
//////////////////////////
//      F I M           //
//////////////////////////

DbSelectArea("VPD")

mBrowse( 6, 1,22,75,"VPD")
Return

Function FS_VCM640(cTp)
Local lRet := .f.
If cTp == "COD"
	DbSelectArea("SB1")
	FG_POSSB1("M->VPD_COD","SB1->B1_COD")
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+M->VPD_COD)
		If M->VPD_COD # M->VPD_CODREL
			lRet := .t.
			M->VPD_GRP := SB1->B1_GRUPO
			M->VPD_ITE := SB1->B1_CODITE
			M->VPD_DES := SB1->B1_DESC
		EndIf
	EndIf
ElseIf cTp == "CODREL"
	DbSelectArea("SB1")
	FG_POSSB1("M->VPD_CODREL","SB1->B1_COD")
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+M->VPD_CODREL)
		If M->VPD_CODREL # M->VPD_COD
			lRet := .t.
			M->VPD_GRPREL := SB1->B1_GRUPO
			M->VPD_ITEREL := SB1->B1_CODITE
			M->VPD_DESREL := SB1->B1_DESC
		else
			MsgInfo(STR0010,STR0009)
		EndIf
	EndIf
Else // Consultar
	lRet := .t.
	FS_FILTRA640("INICIAL")
	DEFINE MSDIALOG oIteVPD TITLE (STR0001+" - "+STR0002) From 5,08 to 20,61 of oMainWnd
		@ 008,002 SAY STR0005 SIZE 20,40 OF oIteVPD PIXEL COLOR CLR_BLUE
		@ 007,015 MSGET oGrp VAR cGrp F3 "SBM" VALID FS_VAL_VCM640("GRP") PICTURE "!!!!" SIZE 17,8 OF oIteVPD PIXEL COLOR CLR_BLUE
		@ 007,044 MSGET oCod VAR cCod F3 "VPDA" VALID IF(!Empty(cCod),FS_VAL_VCM640("COD"),.t.) PICTURE "@!" SIZE 55,8 OF oIteVPD PIXEL COLOR CLR_BLUE
		@ 008,102 SAY cDes SIZE 200,20 OF oIteVPD  PIXEL COLOR CLR_RED
		@ 022,002 SAY (STR0001+":") SIZE 80,20 OF oIteVPD PIXEL COLOR CLR_BLUE
		@ 030,002 LISTBOX oLbIteVPD FIELDS HEADER OemToAnsi(STR0006),;  //Grupo
                                         OemToAnsi(STR0007),;  //Codigo Item
                                         OemToAnsi(STR0008) ;  //Descricao
		COLSIZES 20,50,90 SIZE 206,083 OF oIteVPD PIXEL
		oLbIteVPD:SetArray(aIteVPD)
		oLbIteVPD:bLine := { || {aIteVPD[oLbIteVPD:nAt,1],;
                         aIteVPD[oLbIteVPD:nAt,2] ,;
                         aIteVPD[oLbIteVPD:nAt,3] }}
		DEFINE SBUTTON FROM 015,180 TYPE 1 ACTION (oIteVPD:End()) ENABLE OF oIteVPD
	ACTIVATE MSDIALOG oIteVPD CENTER
EndIf
	
Return(lRet)

Static Function FS_FILTRA640(cTp)
	Local nPos := 0
	aIteVPD  := {}
	If cTp # "INICIAL"
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+cGrp+cCod)
		cCodProd := SB1->B1_COD
	Else
		cCodProd := VPD->VPD_COD
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cCodProd)
		cGrp := SB1->B1_GRUPO
		cCod := SB1->B1_CODITE
		cDes := SB1->B1_DESC
	EndIf
	DbSelectArea("VPD")
	DbSetOrder(2)
	DbSeek(xFilial("VPD")+cCodProd)
	Do While !Eof() .and. VPD->VPD_FILIAL == xFilial("VPD") .and. VPD->VPD_CODREL == cCodProd
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+VPD->VPD_COD)
		Aadd(aIteVPD,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC})
	   DbSelectArea("VPD")
	   DbSkip()
	EndDo
	DbSelectArea("VPD")
	DbSetOrder(1)
	DbSeek(xFilial("VPD")+cCodProd)
	Do While !Eof() .and. VPD->VPD_FILIAL == xFilial("VPD") .and. VPD->VPD_COD == cCodProd
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+VPD->VPD_CODREL)
		nPos := Ascan(aIteVPD,{|x| x[1]+x[2] == SB1->B1_GRUPO + SB1->B1_CODITE })
  		If nPos <= 0 
			Aadd(aIteVPD,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC})
		EndIf
	   DbSelectArea("VPD")
	   DbSkip()
	EndDo
	If len(aIteVPD) > 0
		aSort(aIteVPD,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
	Else
		Aadd(aIteVPD,{" "," "," "})
	EndIf
	If cTp # "INICIAL"
		oLbIteVPD:SetArray(aIteVPD)
		oLbIteVPD:bLine := { || {aIteVPD[oLbIteVPD:nAt,1],;
	  	                     aIteVPD[oLbIteVPD:nAt,2] ,;
   	  	                  aIteVPD[oLbIteVPD:nAt,3] }}
		oLbIteVPD:SetFocus()
		oLbIteVPD:Refresh()
	EndIf
Return()

Static Function FS_VAL_VCM640(cTp)
Local lRet := .f.
aIteVPD := {}
cCampo36 := cGrp
cDes := space(50)
If cTp == "GRP"
	If Empty(cGrp)
		lRet := .t.
  	   cCod := space(27)
	Else
		DbSelectArea("SBM")
		DbSetOrder(1)
		If DbSeek(xFilial("SBM")+cGrp)
	     	lRet := .t.
			DbSelectArea("SB1")
			DbSetOrder(7)
			If DbSeek(xFilial("SB1")+cGrp+cCod)
				cDes := SB1->B1_DESC
			Else
	   	   		cCod := space(27)
	   	   		
		 	EndIf

		EndIf
 	EndIf
ElseIf cTp == "COD" 
	If Empty(cGrp) .and. !Empty(cCod)
		If FG_POSSB1("cCod","SB1->B1_CODITE")
	  		cGrp := SB1->B1_GRUPO
			oCod:Refresh()
			oGrp:Refresh()
		EndIf
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(7)
	If DbSeek(xFilial("SB1")+cGrp+cCod)
      lRet := .t.
		cDes := SB1->B1_DESC
 	EndIf
EndIf
FS_FILTRA640(cTp)
Return(lRet)
          
Static Function MenuDef()
Local aRotina := { { STR0002 ,"FS_VCM640", 0 , 1},;	&& Pesquisar
                    { STR0003 ,"VCM640INC", 0 , 3 },;	&& Incluir
                    { STR0004 ,"AXDELETA", 0 , 5 }}	&& Excluir
Return aRotina


//////////////////////////////////////
// CRIA CONSULTA PADRAO FNC - 22271 //
// RAFAEL GONCALVES 01/10/09        //
//////////////////////////////////////

Static Function OFIAtuSXB()
Local aEstrSXB := { "XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM" } 
Local aSXB := {}
Local ni := 0
Local nj := 0

aEstrut := {'XB_ALIAS','XB_TIPO','XB_SEQ','XB_COLUNA','XB_DESCRI','XB_DESCSPA','XB_DESCENG','XB_CONTEM','XB_WCONTEM'}

Aadd(aSXB,{'VPDA','1','01','DB','Itens relacionados','Items relacionados','Related itens','SB1',''})
Aadd(aSXB,{'VPDA','2','01','07','Grupo e Codigo','Grupo y Codigo','Goup and code','',''})
Aadd(aSXB,{'VPDA','2','02','03','Descricao','Descripcion','Description','',''})
Aadd(aSXB,{'VPDA','4','01','01','Grupo','Grupo','Group','B1_GRUPO',''})
Aadd(aSXB,{'VPDA','4','01','02','Codigo','Codigo','Code','B1_CODITE',''})
Aadd(aSXB,{'VPDA','4','01','03','Descricao','Descripcion','Description','B1_DESC',''})
Aadd(aSXB,{'VPDA','4','02','04','Grupo','Grupo','Group','B1_GRUPO',''})
Aadd(aSXB,{'VPDA','4','02','05','Codigo','Codigo','Code','B1_CODITE',''})
Aadd(aSXB,{'VPDA','4','02','06','Descricao','Descripcion','Description','B1_DESC',''})
Aadd(aSXB,{'VPDA','5','01','','','','','SB1->B1_CODITE',''})
Aadd(aSXB,{'VPDA','6','01','','','','','iif(Empty(cGrp),.t.,Alltrim(SB1->B1_GRUPO)==Alltrim(cGrp))',''})

dbSelectArea("SXB")
dbSetOrder(1)
For ni:= 1 To Len(aSXB)
	DbSeek(Left(aSXB[ni,1]+SPACE(6),6)+aSXB[ni,2]+aSXB[ni,3]+Left(aSXB[ni,4]+SPACE(2),2))
	RecLock("SXB",!Found())
	For nj:=1 To Len(aSXB[ni])
		If ( FieldPos(aEstrSXB[nj])>0 .and. aSXB[ni,nj] # NIL )
			FieldPut(FieldPos(aEstrSXB[nj]),aSXB[ni,nj])
		EndIf
	Next nj
	dbCommit()
	MsUnLock()
Next ni

Return

Function VCM640INC(cAlias,nReg,nOpc)
Local aParam := {}

aAdd( aParam,  {|| /*U_Before()*/ } )  		//antes da abertura
aAdd( aParam,  {|| VCM640DUP() } )  		//ao clicar no botao ok
aAdd( aParam,  {|| /*U_Transaction()*/ } ) //durante a transacao
aAdd( aParam,  {|| /*U_Fim()*/ } )       	//termino da transacao 

nRet := AxInclui(cAlias,nReg,nOpc,,,,,.F.,,,aParam)
If ExistBlock("VCM640DINC") .and. nRet == 1
	ExecBlock("VCM640DINC",.f.,.f.)
EndIf
//
return .t.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rafael Goncalves - 21/11/09               ³
//³FNC 27750                                 ³
//³funcao para evitar duplicidade no cadastro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function VCM640DUP()
Local lRet := .t. 
Local cQuery := ""
Local cQAlVPD:="SQLVPD"
cQuery  := "SELECT COUNT(VPD.VPD_COD) QTD FROM "+RetSqlName("VPD")+" VPD "
cQuery  += "WHERE VPD.VPD_FILIAL='"+xFilial("VPD")+"' AND "
cQuery  += "VPD.VPD_COD='"+M->VPD_COD+"' AND "
cQuery  += "VPD.VPD_CODREL='"+M->VPD_CODREL+"' AND VPD.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPD , .F. , .T. )

If( cQAlVPD )->( QTD )<=0
	lRet := .t.
Else
	MsgAlert(STR0011)//Já existe relacionamento entre os itens selecionados.
    lRet := .f.
EndIf
( cQAlVPD )->( dbCloseArea() )
Return(lRet)