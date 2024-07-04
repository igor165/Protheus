// �����������������ͻ
// � Versao � 24     �
// �����������������ͼ

#INCLUDE "protheus.ch"
#INCLUDE "VEICM600.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VEICM600 � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Registro de Satisfacao / Insatisfacao do Cliente           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEICM600()
Private aMemos  := {{"VAO_RECLAO","VAO_RECLAM"}}
Private cReclam := ""
Private nReclam := 0
Private aCampos := {}
Private cCadastro := (STR0001)
Private cUsuRes := ""
Private dDatPro := cTod("")
Private cDepart := ""
Private cTipRec := ""
Private dDatEnc := cTod("")
Private aRotina := MenuDef()
Private aCores  := {}
Private cFilVAQ := xFilial("VAQ")
Private cNamVAQ := RetSQLName("VAQ")
Private lVAOVAQ := ( xFilial("VAO") == xFilial("VAQ") ) // ( VAO_FILIAL == VAQ_FILIAL )
If VAQ->(FieldPos("VAQ_TIPOSI")) > 0
	aCores := {	{ 'VCM600VAQ() <> "1" .and. VAO->VAO_SITUAC == "0"', 'BR_VERMELHO'	} ,;	// Insatisfacao - Aberto
				{ 'VCM600VAQ() <> "1" .and. VAO->VAO_SITUAC == "1"', 'BR_AMARELO'	} ,;	// Insatisfacao - Prorrogado
				{ 'VCM600VAQ() <> "1" .and. VAO->VAO_SITUAC == "2"', 'BR_VERDE' 	} ,;	// Insatisfacao - Encerrado
				{ 'VCM600VAQ() == "1" .and. VAO->VAO_SITUAC == "0"', 'f7_verm'		} ,;	// Satisfacao - Aberto
				{ 'VCM600VAQ() == "1" .and. VAO->VAO_SITUAC == "1"', 'f5_amar'		} ,;	// Satisfacao - Prorrogado
				{ 'VCM600VAQ() == "1" .and. VAO->VAO_SITUAC == "2"', 'f10_verd'		} }		// Satisfacao - Encerrado				
Else
	aCores := {	{ 'VAO->VAO_SITUAC == "0"', 'BR_VERMELHO' } ,;	// Aberto
				{ 'VAO->VAO_SITUAC == "1"', 'BR_AMARELO'  } ,;	// Prorrogado
				{ 'VAO->VAO_SITUAC == "2"', 'BR_VERDE' } }		// Encerrado
EndIf
mBrowse( 6, 1,22,75,"VAO",,,,,,aCores)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VCM600VAQ� Autor � Andre Luis Almeida    � Data � 24/07/13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o Tipo de Registro 1=Satisfacao / 0=Insatisfacao   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VCM600VAQ()
If lVAOVAQ // ( VAO_FILIAL == VAQ_FILIAL )
	cFilVAQ := VAO->VAO_FILIAL
EndIf
Return FM_SQL("SELECT VAQ.VAQ_TIPOSI FROM "+cNamVAQ+" VAQ WHERE VAQ.VAQ_FILIAL='"+cFilVAQ+"' AND VAQ.VAQ_TIPREC='"+VAO->VAO_TIPREC+"' AND VAQ.D_E_L_E_T_ = ' '")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ML600V   � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Visualizar Registro de Satisfacao / Insatisfacao do Cliente���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ML600V(cAlias,nReg,nOpc)
CAMPOM600()
AxVisual(cAlias,nReg,nOpc,aCampos)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ML600I   � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Incluir - Registro de Satisfacao / Insatisfacao do Cliente ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ML600I(cAlias,nReg,nOpc)
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAO")
While !Eof() .and. (X3_arquivo == "VAO")
	&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	If Alltrim(x3_campo) == "VAO_RECLAM"
		nReclam := x3_tamanho
	EndIf
	dbskip()
Enddo
cTudOK := "ML600IVal()"
CAMPOM600()
If AxInclui(cAlias,nReg,nOpc,aCampos,,,cTudOK) == 1
	If ExistBlock("VCM600AI")
		ExecBlock("VCM600AI",.f.,.f., { "I" } )
	EndIf
	DbSelectArea("VAO")
	RecLock("VAO",.f.)
	M->VAO_RECLAM := Alltrim(M->VAO_RECLAM)+Chr(13)+Chr(10)+"*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+STR0025+" ***"+Chr(13)+Chr(10)+Repl("_",nReclam)+Chr(13)+Chr(10)
	MSMM(VAO->VAO_RECLAO,TamSx3("VAO_RECLAM")[1],,&(aMemos[1][2]),1,,,"VAO","VAO_RECLAO")
	MsUnlock()
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ML600A   � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Alterar - Registro de Satisfacao / Insatisfacao do Cliente ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ML600A(cAlias,nReg,nOpc)
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAO")
While !Eof() .and. (X3_arquivo == "VAO")
	&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	If Alltrim(x3_campo) == "VAO_RECLAM"
		nReclam := x3_tamanho
	EndIf
	dbskip()
Enddo
cUsuRes := ""
dDatPro := cTod("")
cDepart := ""
cTipRec := ""
dDatEnc := cTod("")
cUsuRes := VAO->VAO_USURES
dDatPro := VAO->VAO_DATPRO
cDepart := VAO->VAO_DEPART
cTipRec := VAO->VAO_TIPREC
dDatEnc := VAO->VAO_DATENC
cTudOK := "ML600AVal()"
CAMPOM600()
DbSelectArea("VAO")
cReclam := M->VAO_RECLAM
If AxAltera(cAlias,nReg,nOpc,aCampos,,,,cTudOK) == 1
	If ExistBlock("VCM600AI")
		ExecBlock("VCM600AI",.f.,.f., { "A" } )
	EndIf
EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VCM600VAL � Autor � Andre Luis Almeida   � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacoes Registro de Satisfacao / Insatisfacao do Cliente���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VCM600VAL(cT)
Local lRet := .t.
Do Case
	Case cT == "OK"
		If !Inclui .and. !Empty(VAO->VAO_DATENC)
			lRet := .f.
		EndIf
	Case cT == "DTP"
		If Inclui .or. !Empty(VAO->VAO_DATENC)
			lRet := .f.
		EndIf
	Case cT == "HRP"
		If Inclui .or. !Empty(VAO->VAO_HORENC)
			lRet := .f.
		EndIf
	Case cT == "TIPTEM"
		If FM_SQL("SELECT R_E_C_N_O_ REC FROM "+RetSQLName("VO4")+" WHERE VO4_FILIAL='"+M->VAO_FILORI+"' AND VO4_NUMOSV='"+Alltrim(M->VAO_ORIGEM)+"' AND VO4_TIPTEM='"+M->VAO_TIPTEM+"' AND D_E_L_E_T_=' '") == 0
			lRet := .f.
		EndIf
	Case cT == "CODPRO"
		If FM_SQL("SELECT R_E_C_N_O_ REC FROM "+RetSQLName("VO4")+" WHERE VO4_FILIAL='"+M->VAO_FILORI+"' AND VO4_NUMOSV='"+Alltrim(M->VAO_ORIGEM)+"' AND VO4_CODPRO='"+M->VAO_CODPRO+"' AND D_E_L_E_T_=' '") == 0
			lRet := .f.
		EndIf
	OtherWise
		If cT == "PRO"
			DbSelectArea("VAP")
			DbSetOrder(1)
			DbSeek( xFilial("VAP") + M->VAO_DEPART )
			If !Empty(M->VAO_DATPRO) .and. ( M->VAO_DATPRO < dDatabase .or. M->VAO_DATPRO > ( M->VAO_DATREC + VAP->VAP_PRAPRO ) )
				lRet := .f.
			EndIf
		ElseIf cT == "ENC"
			If !Empty(M->VAO_DATENC) .and. ( M->VAO_DATENC > dDataBase .or. M->VAO_DATENC < M->VAO_DATREC )
				lRet := .f.
			EndIf
		EndIf
		M->VAO_SITUAC := "0"
		If !Empty(M->VAO_DATENC)
			M->VAO_SITUAC := "2"
		ElseIf !Empty(M->VAO_DATPRO)
			M->VAO_SITUAC := "1"
		EndIf
EndCase
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ML600IVal� Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao do Incluir                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ML600IVal()
Local lRet := .t.
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ML600AVal� Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao do Alterar                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ML600AVal()
Local cImp := ""
Local nReclam := 0

DbSelectArea("SX3")
DbSetOrder(2)
If (DbSeek("VAO_RECLAM"))
	nReclam := x3_tamanho
EndIf

If !ML600IVal()
	Return(.f.)
EndIf
If !(Substr( cReclam , 1, Len(cReclam) ) == Substr( M->VAO_RECLAM , 1, Len(cReclam) )) .or. !VCM600VAL("OK")
	MsgStop(STR0008,STR0007)
	Return(.f.)
EndIf
If !Empty(M->VAO_RECLAM) .And. right( M->VAO_RECLAM , 30 ) # (Repl("_",28)+Chr(13)+Chr(10))
	M->VAO_RECLAM += Chr(13)+Chr(10)
EndIf
If cUsuRes # M->VAO_USURES
	cImp += STR0009+left(Alltrim(UsrRetName(cUsuRes)),10)+" -> "+left(Alltrim(UsrRetName(M->VAO_USURES)),10)+"."+Chr(13)+Chr(10)
EndIf
If dDatPro # M->VAO_DATPRO
	cImp += STR0010+Transform(dDatPro,"@D")+" -> "+Transform(M->VAO_DATPRO,"@D")+"."+Chr(13)+Chr(10)
EndIf
If cDepart # M->VAO_DEPART
	cImp += STR0011+cDepart+" -> "+M->VAO_DEPART+"."+Chr(13)+Chr(10)
EndIf
If cTipRec # M->VAO_TIPREC
	cImp += STR0012+cTipRec+" -> "+M->VAO_TIPREC+"."+Chr(13)+Chr(10)
EndIf
If	dDatEnc # M->VAO_DATENC
	cImp += STR0013+Transform(M->VAO_DATENC,"@D")+"."+Chr(13)+Chr(10)
EndIf
If !Empty(cImp)
	M->VAO_RECLAM += cImp
EndIf
If !Empty(M->VAO_RECLAM) .And. right( M->VAO_RECLAM , 30 ) # (Repl("_",28)+Chr(13)+Chr(10))
	If Empty(cImp)
		M->VAO_RECLAM += Chr(13)+Chr(10)
	EndIf
	M->VAO_RECLAM += "*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+STR0025+" ***"
	M->VAO_RECLAM += Chr(13)+Chr(10)+Repl("_",nReclam)+Chr(13)+Chr(10)
EndIf
Return(.t.)

/*                      
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CAMPOM600� Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Levanta Campos do VAO                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CAMPOM600()

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID) 

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAO02")
aCampos := {}
do While !eof() .and. x3_arquivo == "VAO"
	if VAI->VAI_ENCRAI == "1"
		If X3USO(x3_usado).And.x3_nivel > 0
			aadd(aCampos,x3_campo)
		EndIf
	Else
		If X3USO(x3_usado).And.x3_nivel > 0 .And. !(Alltrim(x3_campo) $ "VAO_DATENC/VAO_HORENC")
			aadd(aCampos,x3_campo)
		EndIf
	Endif	
	dbskip()
Enddo
DbSelectArea("VAO")
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CM600LEG � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Legenda do Browse VAO                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CM600LEG() // Legenda
Local aLegenda := {}
If VAQ->(FieldPos("VAQ_TIPOSI")) > 0
	aLegenda := {	{'',STR0019},;					// Insatisfacao
					{ 'BR_VERMELHO', STR0014  },;	// Aberto
					{ 'BR_AMARELO' , STR0015  },;	// Prorrogado
					{ 'BR_VERDE'   , STR0016  },;	// Encerrado
					{'',"----------------------------------------------"},;
					{'',STR0021},;					// Satisfacao
					{ 'f7_verm'    , STR0014  },;	// Aberto
					{ 'f5_amar'    , STR0015  },;	// Prorrogado
					{ 'f10_verd'   , STR0016 }}		// Encerrado
Else
	aLegenda := {	{ 'BR_VERMELHO', STR0014  },;	// Aberto
					{ 'BR_AMARELO' , STR0015  },;	// Prorrogado
					{ 'BR_VERDE'   , STR0016 }}		// Encerrado
EndIf
BrwLegenda(cCadastro,STR0006,aLegenda)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CM600AGE � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Levanta Campos do VC1 e gera nova Agenda CEV (VC1)         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CM600AGE()
Local cCposVC1  := ""
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
//
cCposVC1 := "VC1_DATVIS/VC1_CODABO/VC1_DESABO/VC1_TIPCON/VC1_DESCON/VC1_OCORRE/VC1_OCOMEM/VC1_ESTVEI/VC1_CODMAR/VC1_DESMAR/VC1_MODVEI/VC1_DESMOD/"
cCposVC1 += "VC1_QTDINT/VC1_DATINT/VC1_PREPAG/VC1_DESPAG/VC1_PROCON/VC1_PROVEN/VC1_PROTPA/VC1_MOTIVO/VC1_CONPRO/"
//
aMemos  := {{"VC1_OCOMEM","VC1_OCORRE"}}
aMemObj := {{"VC1_OBSOBJ","VC1_OBJETI"}}
aRotina := {{ "P" ,"AxPesqui", 0 , 1},;	// Pesquisar
			{ "V" ,"Ml500V", 0 , 2},;		// Visualizar
			{ "A" ,"Ml500I", 0 , 3},;		// Agendar
			{ "R" ,"Ml500A", 0 , 2},;		// Registra Abordagem
			{ "2" ,"Ml5002", 0 , 2},;		// 2a. Via
			{ "E" ,"Ml500E", 0 , 5} }		// Excluir
cCadastro := (STR0020)
cAlias := "VC1"
nOpc := 3
nReg := 0
aCampos := {}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VC102")
Do While !eof() .and. x3_arquivo == "VC1"
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo) $ cCposVC1 )
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
EndDo
DbSelectArea("VC1")
M->VC1_OBJETI := ""
If AxInclui(cAlias,nReg,nOpc,aCampos,,,"VCM510VAL('3')") == 1 // VCM510VAL() -> Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
	MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],,&(aMemObj[1][2]),1,,,"VC1","VC1_OBSOBJ")
	MsgInfo(STR0018,STR0007)
EndIf
cCadastro := (STR0001)
//////////////////////////////////
// Voltar aMemos da rotina      //
//////////////////////////////////
aMemos  := {{"VAO_RECLAO","VAO_RECLAM"}}
//////////////////////////////////
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Andre Luis Almeida    � Data � 05/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta aRotina (MenuDef)                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRecebe
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},; // Pesquisar
				{ STR0003 ,"Ml600V", 0 , 2},;		// Visualizar
				{ STR0004 ,"Ml600I", 0 , 3},;		// Incluir
				{ STR0005 ,"Ml600A", 0 , 4},;		// Alterar
				{ STR0006 ,"CM600LEG",0, 2,0,.f.},;	// Legenda
				{ STR0017 ,"CM600AGE",0,3}}		// Criar Agenda     

if ExistBlock("VCM600MN")
	aRecebe := ExecBlock("VCM600MN",.f.,.f.,{aRotina} )
Endif
If Valtype(aRecebe) == "A"
	aRotina := aClone(aRecebe)
Endif
				
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VCM600F3 � Autor � Andre Luis Almeida    � Data � 28/07/14 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � F3 do Tipo de Tempo e Produtivo da OS                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VCM600F3(cAliasF3)
Local lRet      := .f.
Local aAux      := {}
Local aRet      := {}
Local cQuery    := ""
Local cQAlias   := "SQLAUX"
Local aParamBox := {}
If cAliasF3 == "VOI" // Tipo de Tempo
	cQuery := "SELECT DISTINCT VO4.VO4_TIPTEM , VOI.VOI_DESTTE FROM "+RetSQLName("VO4")+" VO4 "
	cQuery += "LEFT JOIN "+RetSQLName("VOI")+" VOI ON ( VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VO4.VO4_FILIAL='"+M->VAO_FILORI+"' AND VO4.VO4_NUMOSV='"+Alltrim(M->VAO_ORIGEM)+"' AND VO4.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aAux,( cQAlias )->( VO4_TIPTEM )+"="+( cQAlias )->( VOI_DESTTE ))
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	aAdd(aParamBox,{2,"Tipo de Tempo","",aAux,90,".t.",.f.})
	DbSelectArea("VOI")
	DbSetOrder(1) // VOI_FILIAL+VOI_TIPTEM
	If ParamBox(aParamBox,"Tipo de Tempo",@aRet,,,,,,,,.f.)
		VOI->(DbSeek(xFilial("VOI")+aRet[1]))
		lRet := .t.
	EndIf
ElseIf cAliasF3 == "VAI" // Produtivos
	cQuery := "SELECT DISTINCT VO4.VO4_CODPRO , VAI.VAI_NOMTEC FROM "+RetSQLName("VO4")+" VO4 "
	cQuery += "LEFT JOIN "+RetSQLName("VAI")+" VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VO4.VO4_CODPRO AND VAI.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VO4.VO4_FILIAL='"+M->VAO_FILORI+"' AND VO4.VO4_NUMOSV='"+Alltrim(M->VAO_ORIGEM)+"' AND VO4.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aAux,( cQAlias )->( VO4_CODPRO )+"="+( cQAlias )->( VAI_NOMTEC ))
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	aAdd(aParamBox,{2,"Produtivo","",aAux,90,".t.",.f.})
	DbSelectArea("VAI")
	DbSetOrder(1) // VAI_FILIAL+VAI_CODTEC
	If ParamBox(aParamBox,"Produtivo",@aRet,,,,,,,,.f.)
		VAI->(DbSeek(xFilial("VAI")+aRet[1]))
		lRet := .t.
	EndIf
EndIf
Return(lRet)