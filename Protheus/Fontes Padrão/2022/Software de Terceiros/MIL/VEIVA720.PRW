// 浜様様様曜様様様様�
// � Versao � 4      �
// 藩様様様擁様様様様�

#INCLUDE "VEIVA720.CH"
#INCLUDE "Protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEIVA720 � Autor �Thiago				    � Data � 29/09/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Controle de Documentos do Veiculo.	                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      �Generico                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA720()

PRIVATE aRotina := MenuDef()

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define o cabecalho da tela de atualizacoes                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE cCadastro := OemToAnsi(STR0001) //"controle de Documentos do Veiculo"

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
mBrowse( 6, 1,22,75,"VV1")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA720     �Autor  �Thiago              � Data �  29/09/11   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta Tela.                                                 艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA720(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local lProcura := .t. , i := 0 , nCntFor := 0 , _ni := 0 , _lRet := .f. , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cAliasVD0 := "SQLVD0"
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  := {} , aCols := {} , aHeader := {}
Private nCadRap := 0

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RegToMemory("VV1",.T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !Eof().and.(x3_arquivo=="VV1")
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	DbSkip()
End
If !Inclui
	DbSelectArea("VV1")
	For nCntFor := 1 To FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

If nOpc == 3
	nOpcG := 3
ElseIf nOpc == 4
	nOpcG := 4
ElseIf nOpc == 2
	nOpcG := 2
Else
	nOpcG := 5
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
DbSelectArea("SX3")
DbSeek("VD0")
aHeader:={}
While !Eof().And.(x3_arquivo=="VD0")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		
	Endif
	
	DbSkip()
	
End
aCols := {}
n := 1
if nOpc <> 3
	nReg    := 1
	cQuery := "SELECT VD0.VD0_CHAINT,VD0.VD0_ANOREF,VD0.VD0_CODDES,VD0.VD0_DESDES,VD0.VD0_OBSERV,VD0.VD0_DATVEN,VD0.VD0_VALDES,VD0.VD0_DTEFPG "
	cQuery += "FROM " + RetSqlName( "VD0" ) + " VD0 WHERE "
	cQuery += "VD0.VD0_FILIAL='"+xFilial("VD0")+"' AND VD0.VD0_CHAINT = '"+VV1->VV1_CHAINT+"' AND "
	cQuery += "VD0.D_E_L_E_T_=' '" 
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD0, .T., .T. )
	Do While !( cAliasVD0 )->( Eof() )
		Aadd(aCols, Array(Len(aHeader)+1) )
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[nReg,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[nReg,FG_POSVAR("VD0_CHAINT")] := ( cAliasVD0 )->VD0_CHAINT
		aCols[nReg,FG_POSVAR("VD0_ANOREF")] := ( cAliasVD0 )->VD0_ANOREF
		aCols[nReg,FG_POSVAR("VD0_CODDES")] := ( cAliasVD0 )->VD0_CODDES
		aCols[nReg,FG_POSVAR("VD0_DESDES")] := ( cAliasVD0 )->VD0_DESDES
		aCols[nReg,FG_POSVAR("VD0_OBSERV")] := ( cAliasVD0 )->VD0_OBSERV
		aCols[nReg,FG_POSVAR("VD0_DATVEN")] := stod(( cAliasVD0 )->VD0_DATVEN)
		aCols[nReg,FG_POSVAR("VD0_VALDES")] := ( cAliasVD0 )->VD0_VALDES
		aCols[nReg,FG_POSVAR("VD0_DTEFPG")] := stod(( cAliasVD0 )->VD0_DTEFPG)
		aCols[nReg,Len(aCols[1])] := .f.
		nReg++
		dbSelectArea(cAliasVD0)
		( cAliasVD0 )->(dbSkip())
	Enddo
	( cAliasVD0 )->(dbCloseArea())
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Executa a Modelo 3                                           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
cTitulo        := STR0001
cAliasEnchoice := "VV1"
cAliasGetD     := "VD0"
//cLinOk         := "FG_OBRIGAT()"
cLinOk         := "VA720LINOK()"
cTudOk         := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR(),FS_TACOLS()"


// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 75 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
nLenCon  :=Len(aCols)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
EnChoice(cAliasEnchoice,nReg,2,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
oGetDados:oBrowse:bChange := {|| FG_AALTER("VD0",nLenCon,oGetDados) }
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(oGetDados:TudoOk().And.FS_VA720GRA(nOpc), oDlg:End() , .f. ) },{|| oDlg:End() })

Return(.t.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA720R    �Autor  �Thiago              � Data �  29/09/11   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta Tela para cadastramento rapido.                       艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA720R(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local lProcura := .t. , i := 0 , nCntFor := 0 , _ni := 0 , _lRet := .f. , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local cChassi := space(30)
Local cAno    := space(4)
Private cAliasVD0 := "SQLVD0"
Private aCpoEnchoice  := {} , aCols := {} , aHeader := {}

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

RegToMemory("VV1",.T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV1")
While !Eof().and.(x3_arquivo=="VV1")
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	DbSkip()
End
If !Inclui
	DbSelectArea("VV1")
	For nCntFor := 1 To FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

If nOpc == 3 .or. nOpc == 6  
    if nOpc == 6 
       nCadRap := 1     
    Endif   
	nOpcG := 3
ElseIf nOpc == 4
	nOpcG := 4
ElseIf nOpc == 2
	nOpcG := 2
Else
	nOpcG := 5
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
DbSelectArea("SX3")
DbSeek("VD0")
aHeader:={}
While !Eof().And.(x3_arquivo=="VD0")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel .and. !(X3_CAMPO $ "VD0_CHAINT/VD0_ANOREF/VD0_OBSERV/VD0_DTEFPG")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		
	Endif
	
	DbSkip()
	
End
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"V6")
nReg    := 1
aCols := {}
n := 1
While !Eof() .and. SX5->X5_TABELA == "V6"
	Aadd(aCols, Array(Len(aHeader)+1) )
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[nReg,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	aCols[nReg,FG_POSVAR("VD0_CODDES")] := SX5->X5_CHAVE
	aCols[nReg,FG_POSVAR("VD0_DESDES")] := SX5->X5_DESCRI
	aCols[nReg,FG_POSVAR("VD0_DATVEN")] := stod("  /  /  ")
	aCols[nReg,FG_POSVAR("VD0_VALDES")] := 0
	aCols[nReg,Len(aCols[1])] := .f.
	nReg++
	dbSelectArea("SX5")
	dbSkip()
Enddo

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Executa a Modelo 3                                           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
cTitulo        := STR0001
cAliasEnchoice := "VV1"
cAliasGetD     := "VD0"
cLinOk         := "VA720LINOK()"
cTudOk         := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR(),FS_TACOLS()"

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0002) FROM  01,11 TO 25,85 OF oMainWnd
@ 016, 003 TO 039,160 LABEL STR0003 OF oDlg1 PIXEL
@ 016, 162 TO 039,290 LABEL STR0004 OF oDlg1 PIXEL
@ 024,008 SAY STR0005 SIZE 702,40  Of oDlg1 PIXEL COLOR CLR_HRED
@ 024,035 MSGET oChassi VAR VV1->VV1_CHASSI PICTURE "@!" SIZE 85,08 OF oDlg1 PIXEL COLOR CLR_BLUE WHEN .f.

@ 024,170 SAY STR0006 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_HRED
@ 024,185 MSGET oAno VAR cAno PICTURE "@R 9999" SIZE 35,08 OF oDlg1 PIXEL COLOR CLR_BLUE
oGetDados := MsGetDados():New(039,003,170,290,nOpcG,cLinOk,cTudOk,"",.T.,{"VD0_VALDES","VD0_DATVEN"},,,,cFieldOk,,,,oDlg1)
ACTIVATE MSDIALOG oDlg1 CENTER ON INIT EnchoiceBar(oDlg1,{|| if(oGetDados:TudoOk().And.FS_CADRAPIDO(cAno), oDlg1:End() , .f. ) },{|| oDlg1:End() })

Return(.t.)


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様用様様様様様様曜様様様用様様様様様様様様様様僕様様用様様様様様様融臼
臼�Programa  �FS_VA720GRA  �Autor  �Microsiga           � Data �  09/06/00   艮�
臼麺様様様様謡様様様様様様擁様様様溶様様様様様様様様様様瞥様様溶様様様様様様郵臼
臼�Desc.     �Gravacao                                                       艮�
臼�          �                                                               艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼�Uso       � AP5                                                           艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function FS_VA720GRA(nOpc)

Local lRet := .t.  , i := 0

If nOpc # 2
	
	Begin Transaction
	
	For i:=1 to len(aCols)
		if Empty(aCols[i,FG_POSVAR("VD0_CHAINT")]) .or. Empty(aCols[i,FG_POSVAR("VD0_ANOREF")]) .or. Empty(aCols[i,FG_POSVAR("VD0_CODDES")])
			loop
		Endif
		If nOpc == 3
			If !aCols[i,Len(aCols[i])]
				dbSelectArea("VD0")
				dbSetOrder(1)
				lRet := dbSeek(xFilial("VD0")+aCols[i,FG_POSVAR("VD0_CHAINT")]+aCols[i,FG_POSVAR("VD0_ANOREF")]+aCols[i,FG_POSVAR("VD0_CODDES")])
				if lRet 
				   MsgInfo(STR0018+" - "+aCols[i,FG_POSVAR("VD0_DESDES")])
				   Return(.f.)
				Else    
					RecLock("VD0", .t. )
					FG_GRAVAR("VD0",aCols,aHeader,i)
					MsUnlock()
				Endif	
			Else
				If Found()
					RecLock("VD0",.F.,.T.)
					Dbdelete()
					WriteSx2("VD0")
					MsUnlock()
				Endif
			Endif
		Endif
		if nOpc == 4
			If !aCols[i,Len(aCols[i])]
				
				dbSelectArea("VD0")
				dbSetOrder(1)
				lRet := dbSeek(xFilial("VD0")+aCols[i,FG_POSVAR("VD0_CHAINT")]+aCols[i,FG_POSVAR("VD0_ANOREF")]+aCols[i,FG_POSVAR("VD0_CODDES")])
				RecLock("VD0", !lRet )
				FG_GRAVAR("VD0",aCols,aHeader,i)
				MsUnlock()
			Else
				dbSelectArea("VD0")
				dbSetOrder(1)
				lRet := dbSeek(xFilial("VD0")+aCols[i,FG_POSVAR("VD0_CHAINT")]+aCols[i,FG_POSVAR("VD0_ANOREF")]+aCols[i,FG_POSVAR("VD0_CODDES")])
				If lRet
					RecLock("VD0",.F.,.T.)
					Dbdelete()
					WriteSx2("VD0")
					MsUnlock()
				Endif
			Endif
		Endif
		If nOpc == 5
	 		dbSelectArea("VD0")
			dbSetOrder(1)
			if dbSeek(xFilial("VD0")+aCols[i,FG_POSVAR("VD0_CHAINT")]+aCols[i,FG_POSVAR("VD0_ANOREF")]+aCols[i,FG_POSVAR("VD0_CODDES")])
			   While !Eof() .and. xFilial("VD0") == VD0->VD0_FILIAL .and. VD0->VD0_CHAINT == aCols[i,FG_POSVAR("VD0_CHAINT")] .and. VD0->VD0_ANOREF == aCols[i,FG_POSVAR("VD0_ANOREF")] .and. VD0->VD0_CODDES == aCols[i,FG_POSVAR("VD0_CODDES")]
				  RecLock("VD0",.F.,.T.)
				  Dbdelete()
				  WriteSx2("VD0")
				  MsUnlock()
				  dbSelectArea("VD0")
				  dbSkip()
               Enddo
			Endif
    	Endif
	Next
	
	End Transaction
	
Endif
oDlg:End()
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Fun��o    �FS_CADRAPIDO� Autor �Thiago		   		     � Data � 29/09/11 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descri��o �Cadastramento rapido.					                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼� Uso      �Generico                                                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function FS_CADRAPIDO(cAno)

Local i := 0

if Empty(cAno)
	MsgInfo(STR0007)
	Return(.f.)
Endif

For i:=1 to Len(aCols)
	
	if Empty(aCols[i,FG_POSVAR("VD0_VALDES")]) .and. Empty(aCols[i,FG_POSVAR("VD0_DATVEN")])
		Loop
	Endif
	dbSelectArea("VD0")
	dbSetOrder(1)
	if dbSeek(xFilial("VD0")+VV1->VV1_CHAINT+cAno+aCols[i,FG_POSVAR("VD0_CODDES")])
		MsgInfo(STR0016+" - "+aCols[i,FG_POSVAR("VD0_DESDES")])
		Loop
	Endif
	if !Empty(aCols[i,FG_POSVAR("VD0_VALDES")])
		if Empty(aCols[i,FG_POSVAR("VD0_DATVEN")])
			MsgInfo(STR0008)
			Return(.f.)
		Endif
	Endif
	if !Empty(aCols[i,FG_POSVAR("VD0_DATVEN")])
		if Empty(aCols[i,FG_POSVAR("VD0_VALDES")])
			MsgInfo(STR0009)
			Return(.f.)
		Endif
	Endif
	dbSelectArea("VD0")
	RecLock("VD0",.t.)
	VD0->VD0_FILIAL := xFilial("VD0")
	VD0->VD0_CHAINT := VV1->VV1_CHAINT
	VD0->VD0_ANOREF := cAno
	VD0->VD0_CODDES := aCols[i,FG_POSVAR("VD0_CODDES")]
	VD0->VD0_CODDES := aCols[i,FG_POSVAR("VD0_CODDES")]
	VD0->VD0_DESDES := aCols[i,FG_POSVAR("VD0_DESDES")]
	VD0->VD0_DATVEN := aCols[i,FG_POSVAR("VD0_DATVEN")]
	VD0->VD0_VALDES := aCols[i,FG_POSVAR("VD0_VALDES")]
	MsUnlock()
Next

Return(.t.)
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Fun��o    �VA720VALID  � Autor �Thiago		   		     � Data � 29/09/11 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descri��o �Validacao na digitacao do Codigo da Despesa          咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼� Uso      �Generico                                                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VA720VALID()
Local i := 0
lRet := .t.
For i:=1 to Len(aCols)
	if i <> n
		if aCols[i,FG_POSVAR("VD0_ANOREF")] == M->VD0_ANOREF .and. aCols[i,FG_POSVAR("VD0_CODDES")] == M->VD0_CODDES
			MsgInfo(STR0017)
			lRet := .f.
		Endif
	Endif
Next
Return(lRet)
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Fun��o    �VA720LINOK  � Autor �Thiago		   		     � Data � 29/09/11 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descri��o �Validacao na linhaok.					                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼� Uso      �Generico                                                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VA720LINOK()
          
if nCadRap == 1
   Return(.t.)
Endif   
If nOpcG == 3
	If !aCols[n,Len(aCols[n])]
		dbSelectArea("VD0")
		dbSetOrder(1)
		lRet := dbSeek(xFilial("VD0")+aCols[n,FG_POSVAR("VD0_CHAINT")]+aCols[n,FG_POSVAR("VD0_ANOREF")]+aCols[n,FG_POSVAR("VD0_CODDES")])
		if lRet 
		   MsgInfo(STR0018+" - "+aCols[n,FG_POSVAR("VD0_DESDES")])
		   Return(.f.)
		Endif	
	Endif
Endif
If !aCols[n,Len(aCols[n])]
	if !Empty(aCols[n,FG_POSVAR("VD0_VALDES")])
		if Empty(aCols[n,FG_POSVAR("VD0_DATVEN")])
			MsgInfo(STR0008)
			Return(.f.)
		Endif
	Endif
	if !Empty(aCols[n,FG_POSVAR("VD0_DATVEN")])
		if Empty(aCols[n,FG_POSVAR("VD0_VALDES")])
			MsgInfo(STR0009)
			Return(.f.)
		Endif
	Endif
Endif
Return(.t.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � MenuDef	� Autor �Thiago				    � Data � 29/09/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Criacao do menu.						                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      �Generico                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0010 ,"axPesqui", 0 , 1},; //Pesquisar
{ STR0011 ,"VA720", 0 , 2},;  //Visualizar
{ STR0012 ,"VA720", 0 , 3},;  //Incluir
{ STR0013 ,"VA720", 0 , 4},;  //Alterar
{ STR0014 ,"VA720", 0 , 5},;  //Excluir
{ STR0015 ,"VA720R", 0 , 6}}   //Cadastro rapido
Return aRotina
