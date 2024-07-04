#include "VDFA210.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
Static nRadioOpc := 1
Static lGestPubl:= IIF(ExistFunc("fUsaGFP"), fUsaGFP(), .F.)
Static cCtlMenu := 'VDFA210VIS'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFA210    ³ Autor ³ Totvs                    ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico de Atos/Portarias                                       ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivia F.      ³19/11/13³PRJ. M_RH001     ³-GSP-Manutencao de Itens -      		     ³±±
±±³              ³        ³                 ³                                            ³±±
±±³Nivia F.      ³25/11/13³PRJ. M_RH001     ³Historico da vida funcional      		     ³±±
±±³              ³        ³REQ. 002090      ³                                            ³±±
±±³Everson jr    ³26/02/14³PRJ. M_RH001     ³correção na tabela temporaria TRB.          ³±±
±±³              ³        ³REQ. 001851      ³                                            ³±±
±±³Marcos Pereira³24/03/14³PRJ. M_RH001     ³Alterado p/passar a chave em branco p/RI6   ³±±
±±³              ³        ³REQ. 001851      ³quando tabela principal for SRA             ³±±
±±³Marcos Pereira³28/10/15³PCREQ-5343       ³Ajustada a VDFA210OK para reiniciar cItem   ³±±
±±³              ³        ³REQ. 001851      ³quando inclusão de item historico           ³±±
±±³Marcelo Faria ³21/11/16³AUDESP           ³Preparacao da funcionalidade de gestao dos  ³±±
±±³              ³        ³                 ³itens de publicação para o movto de cargos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210
Manutencao de Itens - Incluir/Alterar/Cancelar
@sample 	VDFA210()
@param
@return	Nil
@author	Nivia Ferreira
@since		23/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA210()
Local oBrowse
Local oDlg
Local oRadio
Local nOpca			:= 1
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aMsg			:= aOfusca[3]
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Private aTab		:= {}

If !lBlqAcesso

	cCtlMenu	:= "VDFA210"

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi(STR0080) PIXEL // "Historico de Atos e Portarias"

	@ 10,17 Say OemToAnsi(STR0081) SIZE 150,7 OF oDlg PIXEL
	@ 27,07 TO 72, 140 OF oDlg  PIXEL
	@ 35,10 Radio oRadio VAR nRadioOpc;
			ITEMS 	"Cargo",;	    //"Cargo"
				   	"Matrícula";	//"Matrícula"
			3D SIZE 100,10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso para saida com ESC

	If nOpca == 1
		oBrowse:= FWmBrowse():New()
		oBrowse:SetMenuDef( 'VDFA210' )
		Do Case
			Case nRadioOpc == 1
				If CHKFILE("RI6") .And. RI6->(ColumnPos("RI6_CARGO")) > 0
					oBrowse:SetAlias( 'SQ3' )
					oBrowse:SetDescription( STR0085 )    //'Cargo - Manutenção de Itens'
				Else
					Aviso(STR0086,STR0087,{STR0088})	//"ATENCAO"###"Para esta opção é preciso atualizar o dicionário de dados - AUDESP"###"Sair"
					Return
				EndIf
			Case nRadioOpc == 2
				oBrowse:SetAlias( 'SRA' )
				oBrowse:SetDescription( STR0001 )    //'Servidor - Manutenção de Itens'
				oBrowse:AddLegend( "!(RA_CATFUNC$('789')) .and. Empty(RA_SITFOLH)","GREEN" ,	STR0025) //'Situação Normal'
				GpLegend(@oBrowse,.T.)
		EndCase
		oBrowse:Activate()
	EndIf
Else
	Help(" ",1,aMsg[1],,aMsg[2],1,0)
Endif

Return( NIL )


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Incluindo opção no Menu do browse.

@sample 	MenuDef()

@param

@return	aRotina

@author	Nivia Ferreira
@since		23/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

If !IsInCallStack("VDFA210VIS") .and. !IsInCallStack("VDFA210MAN")
    cCtlMenu := "VDFA210"
EndIf

If  cCtlMenu == "VDFA210"
    // A opção somente estará disponível quando o ambiente for gestão publica
	If (nRadioOpc == 2) .and. lGestPubl
		ADD OPTION aRotina TITLE STR0002 ACTION 'VDFA210VIS()' OPERATION 2 ACCESS 0//'Consulta/Certidao'
		ADD OPTION aRotina TITLE STR0070 ACTION 'VDFA210MAN()' OPERATION 4 ACCESS 0//'Manutenção Itens a Publicar'
	Else
		ADD OPTION aRotina TITLE STR0059 ACTION 'VDFA210VIS()' OPERATION 2 ACCESS 0//'Consulta Atos e Portarias Publicados'
	EndIf
	ADD OPTION aRotina TITLE STR0003  	 ACTION 'VDFA210INC("3")' OPERATION 6 ACCESS 0//'Incluir Hist'
	ADD OPTION aRotina TITLE STR0016  	 ACTION 'VDFA210INC("4")' OPERATION 6 ACCESS 0//'Alterar Hist'
	ADD OPTION aRotina TITLE STR0004  	 ACTION 'VDFA210INC("5")' OPERATION 6 ACCESS 0//'Excluir Hist'
EndIf

Return aRotina





//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210INC
Inclusao de um Item Manual ou Reservado

@sample 	VDFA210INC()

@param		cParam	 3-Incluir
			cTitulo  Titulo do Objeto
			cVisivel .T. ou .F.

@return	Nill

@author	Nivia Ferreira
@since		23/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA210INC(cParam,cTitulo)
Local lRet    	:= .F.
Local lRetEd  	:= .F.
Local bOk      	:= {||lRet:=.T.,oDlg:End()}
Local bCancel		:= {||oDlg:End()}
Local nNumero 	:= ""
Local nAno    	:= ""
Local mChave 		:= ""
Local oComb1
Local cComb1
Local oDlg
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oData

Private cHabili  	:= .F.
Private cAusenc  	:= .F.
Private aComb1   	:= {}
Private cClass   	:= ""
Private cTpdoc   	:= ""
Private cFonte   	:= "VDFA210"
Private dInici  	:= ''
Private cCatFunc 	:= SRA->RA_CATFUNC
Private dEfeito  	:= ctod("  /  /  ")
Private dPublic  	:= ctod("  /  /  ")
Private dDoc  		:= ctod("  /  /  ")

cTpdoc	:= Space(03)
cClass	:= Space(02)
nAno  	:= Space( TamSX3("RI5_ANO")[1] )
nNumero:= Space( TamSX3("RI5_NUMDOC")[1] )

If cParam == "3"
   cTitulo:= STR0044
ElseIf	cParam == "4"
   cTitulo:= STR0045
Else
	cTitulo:= STR0046
Endif

If nRadioOpc == 2 //SRA - Matrículas
   cCatFunc := SRA->RA_CATFUNC
	//Monta combo com os tipos de ausencia
	AAdd(aComb1,'')
	DbSelectArea("RCM")
	DbSetOrder(1)
	RCM->( DbGoTop() )
	While RCM->(!EOF())
		AAdd(aComb1, RCM->RCM_TIPO+"-"+RCM->RCM_DESCRI)
		RCM->( dbSkip() )
	Enddo
Else
   cCatFunc := '1'
EndIf

Begin Sequence

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 32,60 OF oMainWnd

If nRadioOpc == 2 //SRA - Matrículas
	@ 20,005 SAY STR0034 PIXEL //"Servidor: "
	@ 20,055 SAY SRA->RA_MAT +" - " + Alltrim(SRA->RA_NOME) PIXEL
Else
	@ 20,005 SAY STR0079 PIXEL //"Cargo: "
	@ 20,055 SAY SQ3->Q3_CARGO +" - " + Alltrim(SQ3->Q3_DESCSUM) PIXEL
EndIf

@ 33,005 SAY STR0035 OF oDlg PIXEL  //'Tipo Doc:'
@ 33,055 MSGET oGet1 VAR cTpdoc  PICTURE "@!" Valid (VDFTPDOC({"VDFA210",cTpdoc}))  F3 "S100" SIZE 25,8 OF oDlg PIXEL HASBUTTON
@ 33,123 MSGET Alltrim(fDescRCC("S100",cTpdoc,1,3,34,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.


@ 46,005 SAY STR0036 PIXEL//'Classificação:'
@ 46,055 MSGET oGet2 VAR cClass  PICTURE "@!" Valid(VDFCLASSIF({"VDFA210",cTpdoc,cCatFunc,cClass}))F3 "S101" SIZE 29,8 OF oDlg PIXEL HASBUTTON
@ 46,123 MSGET Alltrim(fDescRCC("S101",cClass,1,2,03,20)) VALID {|| ,oDlg:Refresh()} SIZE 90,8  OF oDlg Pixel WHEN .F.


@ 59,005 SAY STR0037 OF oDlg PIXEL//'Numero/Ano'
@ 61,123 SAY STR0038 OF oDlg PIXEL//'Somente quando for historico'
@ 59,055 MSGET oGet3 VAR nNumero  PICTURE "9999" F3 SIZE 25,8 OF oDlg PIXEL HASBUTTON

If cParam <>'3'  // Inclusao
    @ 059,083 MSGET oGet4 VAR nAno  PICTURE "9999" F3 SIZE 25,8 OF oDlg PIXEL HASBUTTON
Else  // Inclusao
   	@ 059,083 MSGET oGet4 VAR nAno  PICTURE "9999" VALID (VDFA210CSF(cClass,nNumero,nAno)) F3 SIZE 25,8 OF oDlg PIXEL HASBUTTON
	@ 076,005 SAY STR0039 PIXEL//'Data de Efeito:'
	@ 076,055 MSGET oData VAR dEfeito  PICTURE "@D" Valid F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON
	@ 095,005 SAY STR0064 PIXEL//'Data de Publicação:'
	@ 095,055 MSGET oData VAR dPublic  PICTURE "@D" Valid F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON
	@ 114,005 SAY STR0066 OF oDlg PIXEL//'Data Documento:'
	@ 114,055 MSGET oData VAR dDoc  PICTURE "@D" Valid F3 SIZE 45,8 OF oDlg PIXEL HASBUTTON
	If nRadioOpc == 2
		@ 133,005 SAY STR0040 OF oDlg PIXEL//'Tipo Ausência'
		@ 133,055 MSCOMBOBOX oComb1 VAR cComb1 ITEMS aComb1 SIZE 130,8 OF oDlg PIXEL WHEN cHabili .and. len(aComb1) > 1
	EndIf
Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=VDFA210OK(cTpdoc,cClass,STRZERO(VAL(nNumero),4),nAno,oDlg,cParam,cComb1,dEfeito)},bCancel)

End Sequence

If lRet
   lRetEd:= .T.
	If cParam== '3' //Inclusao
		If Empty(nNumero) .And. Empty(nAno)
		    mChave := SRA->RA_FILIAL+SRA->RA_MAT
			VDFM210({cClass,cTpdoc,SRA->RA_CATFUNC,SRA->RA_MAT,'SRA','2','',SRA->RA_FILIAL,SRA->RA_CIC,dEfeito,'1','','',''})  //Envia a chave em branco quando for tabela SRA.
		Else
			VDFA210EDT(cTpdoc,cClass,STRZERO(VAL(nNumero),4),nAno,cParam,cComb1,dEfeito,'1')
		Endif
	Endif
	If cParam== '4' //Alteração
	   VDFA210EDT(cTpdoc,cClass,STRZERO(VAL(nNumero),4),nAno,cParam,cComb1)
	Endif
	If cParam== '5' //Exclusao
	   VDFA210EDT(cTpdoc,cClass,STRZERO(VAL(nNumero),4),nAno,cParam,cComb1)
	Endif

Endif

Return (lRet)



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210OK
Validacao do BOTAO OK

@sample 	VDFA210OK()

@param		cTpdoc 	Tipo de Documento S100
			cClass  Classificação     S101
			nNumero Numero do documento
			nAno    Ano do codumento
			oDlg    Objeto
			cParam  3 - Inclusao
					4 - Alterção
					5 - Cancelar

@return		lRet	 .V. ou .F.

@author	    Nivia Ferreira
@since		24/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VDFA210OK(cTpdoc,cClass,nNumero,nAno,oDlg,cParam,cComb1,dEfeito)

Local aArea   := GetArea()
Local mNUMDOC := 0
Local mAno    := 0
local lRet    := .T.
Local cItem	  := ''


If Empty(cTpdoc)
 	MsgInfo(STR0008, '')		//'Informe o tipo de documento.'
	Return(.F.)
Endif

If Empty(cClass)
 	MsgInfo(STR0024, '')//'Informe a classificação.'
	Return(.F.)
Endif

If cAusenc == .T.  //Foi habilitado o tipo de ausencia
	If Empty(cComb1)
    	MsgInfo(STR0010, '')	//'Informe o tipo de ausência.'
		Return(.F.)
	Endif
	If (lRet:= VDFA210AUS(cComb1) ) == .F.
    	MsgInfo(STR0011, '')	//'Data de inicio do afastamento não informado ou não cadastrado.'
		Return(.F.)
	Endif
Endif

If nNumero='0000' .And. Empty(nAno) .And. cParam == '3' .And.  (nRadioOpc == 2)
	If MsgYesNo(STR0042)//'Numero do Documento/Ano não informado. Confirma a inclusão de um novo documento?'
		oDlg:End()
		Return(.T.)
	Endif
Endif

If (nRadioOpc == 1) .And.  nNumero='0000' .And. Empty(nAno)
   	MsgInfo(STR0089, '')	//'"O Numero do Documento/Ano é obrigatorio para o Historico de Atos e Portarias por Cargo"
	Return(.F.)
Endif

If Empty(nNumero) .And. !Empty(nAno)
   	MsgInfo(STR0012, '')	//'Informe o numero do documento.'
	Return(.F.)
Endif

If nNumero<>'0000' .And. Empty(nAno)
   	MsgInfo(STR0013, '')	//'Informe o ano da geração do documento.'
	Return(.F.)
Endif

If Val(nAno) < 1900 .Or. Val(nAno) > YEAR(date())
   	MsgInfo(STR0014, '')	//'Ano informado invalido.'
	Return(.F.)
Endif

If cParam=='3' .And. Empty(dEfeito) .and. x3obrigat("RI6_DTEFEI") //Somente na Inclusao
   MsgInfo(STR0015, '')//'Data de Efeito não informada.'
   Return(.F.)
Endif

If cParam=='3' .And. Empty(dPublic) .and. x3obrigat("RI5_DTAPUB") //Somente na Inclusao
   MsgInfo(STR0065, '')//'Data de Publicação não informada.'
   Return(.F.)
Endif

If cParam=='3' .And. Empty(dDoc) //Somente na Inclusao
   MsgInfo(STR0067, '')//'Data do documento não informado.'
   Return(.F.)
Endif

If nNumero<>'0000' .And. !Empty(nAno) .And. cParam == '3'  // Inclusao Manual

	If nRadioOpc == 2
		//Verifica se ja existe doc/funcionario
		dbSelectArea("RI6")
		DbSetOrder(2)
		If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SRA->RA_CIC))
		   	MsgInfo(STR0017, '')	//'Numero do Documento/Ano ja cadastrado para esse funcionário.'
			Return(.F.)
		Endif
	Else
		//Verifica se ja existe doc/cargo
		dbSelectArea("RI6")
		DbSetOrder(6)
		If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SQ3->Q3_CARGO))
		   	MsgInfo(STR0077, '')	//'Numero do Documento/Ano ja cadastrado para esse cargo.'
			Return(.F.)
		Endif
	Endif

	DbSelectArea("RI5")
	DbSetOrder(1)
	If  RI5->(DbSeek(FWXFILIAL("RI5")+nAno+nNumero+cTpdoc)) .And. (RI5_STATUS $('1,4'))
	   	MsgInfo(STR0018, '')		//'Numero do Documento/Ano ja cadastrado.'
		Return(.F.)
	Endif
	If Select("TRB") > 0
		TRB->( dbCloseArea())
	EndIf
	//Verifica se existe documento com tipo = reservado
	cQuery := " Select RI5_ANO,RI5_NUMDOC,RI5_STATUS"
	cQuery += " From "+RetSqlName("RI5")+" RI5 "
	cQuery += " Where RI5.D_E_L_E_T_ = ' '"
	cQuery += " And RI5_FILIAL='" + FWXFILIAL("RI5")+ "' "
	cQuery += " And RI5_STATUS ='3' "
	cQuery += " And RI5_ANO='"+ nAno +"'"
	cQuery += " And RI5_NUMDOC='"+ nNumero+"'"
	cQuery += " And RI5_TIPDOC='"+ cTpdoc +"'"
	cQuery += " ORDER BY RI5_ANO,RI5_NUMDOC	"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
	If  TRB->(EOF())
		TRB->( dbCloseArea() )

		cSelect:= If( "MSSQL" $ AllTrim(Upper(TcGetDb())) .Or. AllTrim(Upper(TcGetDb())) == 'SYBASE' , " SELECT TOP 1 ", " SELECT " )
		cOracle:= If( "ORACLE" $ AllTrim(Upper(TcGetDb())) , " AND ROWNUM <= 1 " , " " )
		cDB2	:= If( "DB2" $ AllTrim(Upper(TcGetDb())) , " FETCH FIRST 1 ROWS ONLY " , " " )

		//Verifica 1a. documento com tipo = automatico
		cQuery := cSelect+ " RI5_ANO,RI5_NUMDOC,RI5_STATUS"
		cQuery += " From "+RetSqlName("RI5")+" RI5 "
		cQuery += " Where RI5.D_E_L_E_T_ = ' '"
		cQuery += " And RI5_FILIAL='" + FWXFILIAL("RI5")+ "' "
		cQuery += " And RI5_STATUS = '1' "
		cQuery += " And RI5_TIPDOC='"+ cTpdoc +"' "+ cOracle
		cQuery += " ORDER BY RI5_ANO,RI5_NUMDOC " +cDB2
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
		dbSelectArea("TRB")

		If TRB->(!EOF())
			IIf (Alltrim(RI5_NUMDOC)=='',mNUMDOC:=0,mNUMDOC:=Val(RI5_NUMDOC))
			IIf (Alltrim(RI5_ANO)   =='',mANO   :=0,mANO   :=Val(RI5_ANO))

			If Val(nNumero) >= mNUMDOC .And. Val(nAno) >= mANO
	   	        MsgInfo(STR0019, '')					//'Numero do Documento/Ano maior que o numero ja existente.'
				lRet:= .F.
			Endif
		Endif
		TRB->( dbCloseArea() )
	Endif
	cItem := ''

ElseIf cParam == '4' //Alteração

	If nRadioOpc == 2
		//Verifica se existe doc/funcionario
		dbSelectArea("RI6")
		DbSetOrder(2)
		If  !RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SRA->RA_CIC))
	        MsgInfo(STR0021, '')	//'Numero do Documento/Ano não cadastrado para esse funcionário.'
			lRet:= .F.
		Else
			cItem := RI6->RI6_TXTHIS
		Endif
	Else
		//Verifica se existe doc/cargo
		dbSelectArea("RI6")
		DbSetOrder(6)
		If  !RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SQ3->Q3_CARGO))
	        MsgInfo(STR0078, '')	//'Numero do Documento/Ano não cadastrado para esse cargo.'
			lRet:= .F.
		Else
			cItem := RI6->RI6_TXTHIS
		Endif
	EndIf

	//Verifica se ja foi publicado
	DbSelectArea("RI5")
	DbSetOrder(1)
	If  (RI5->(DbSeek(FWXFILIAL("RI5")+nAno+nNumero+cTpdoc))) .And. (RI5_STATUS<>'2')
        MsgInfo(STR0020, '')						//'Documento não pode ser alterado pois ja foi publicado.'
		lRet:= .F.
	Endif

ElseIf cParam == '5' //Exclusão

	//Verifica se item ja foi cadastrado e tipo inclusao = manual
	dbSelectArea("RI6")
	If nRadioOpc == 2
		//valida SRA
		DbSetOrder(2)
		If  !RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SRA->RA_CIC))
    	    MsgInfo(STR0022, '')										//'Numero do Documento/Ano não cadastrado para esse funcionário.'
			lRet:= .F.
       EndIf
    Else
       //valida Cargo
		DbSetOrder(6)
		If  !RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SQ3->Q3_CARGO))
    	    MsgInfo(STR0078, '')										//'Numero do Documento/Ano não cadastrado para esse cargo.'
			lRet:= .F.
       EndIf
   EndIf

	If RI6->RI6_STATUS <> '2' //2=Criado Manualmente
        MsgInfo(STR0023, '')										//'Numero do Documento/Ano não pode ser excluído, pois não foi inserido manualmente.'
		lRet:= .F.
	Else
		cItem := RI6->RI6_TXTHIS
	Endif
Endif

RestArea(aArea)

If lRet == .T.
	oDlg:End()
Endif
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210EDT
Inclusao do historico

@sample 	VDFA210EDT()

@param		cTpdoc	Tipo de Documento S100
			cClass  Classificação     S101
			nNumero	Numero do documento
			nAno    Ano do codumento
			cParam  3 - Inclusao
					4 - Alterção
					5 - Cancelar
			cCombo  tipo de ausência

@return	null

@author	Nivia Ferreira
@since		25/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VDFA210EDT(cTpdoc,cClass,nNumero,nAno,cParam,cCombo)
Local aArea  	:= GetArea()
Local lRet   	:= .F.
Local cTexto 	:= ''
Local bOk   	:= {||lRet:=.T.,cTexto:=oTSmpEdit1:GetText(),oDlg:End()}
Local bCancel := {||oDlg:End()}
Local oDlg
Local oTSmpEdit1

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords		:= {}

Local _TABORI := ''
Local _CHAVE  := ''

Local cItem	  := ''

Static cUserL	:= __cUserID

Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0041 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //'Manutenção de Atos/Portarias '

	oTPanel1 := TScrollArea():New(oDlg,0,0,(aAdvSize[6]/100),(aAdvSize[5]/100),.T.,.T.,.T.)
	oTPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	@ 000,000 MSPANEL oPanel OF oTPanel1 SIZE (aAdvSize[6]/100),(aAdvSize[5]/100) COLOR CLR_HRED
	oTPanel1:SetFrame( oPanel )
	oTPanel1:lReadOnly := .F.
	If cParam == '5'
	   	oTPanel1:lReadOnly := .T.
	Endif

	//nTop, nLeft, nHeight, nWidth , cTitle, cText, nFormat, lShowOkButton, lShowCancelButton, oOwner
	oTSmpEdit1 := tSimpEdit():New( , , , , "",  @cItem, 1, .F., .F.,oTPanel1)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

//Se clicar no Botao Confirmar
If lRet

	Begin Transaction

	//Alteração documento automatico.
	If cParam == '2' .And. !Empty(cTexto)
		RecLock("RI6",.F.)
		RI6_TXTHIS := cTexto
		RI6_OK     := ''
		RI6->(MsUnLock())
	Endif

	If  cParam == '3' .And. !Empty(cTexto)
		DbSelectArea("RI5")
		DbSetOrder(1)
		If !RI5->(DbSeek(FWXFILIAL("RI5")+nAno+nNumero+cTpdoc))
			RecLock("RI5",.T.)
			RI5->RI5_FILIAL := FWxFilial("RI5")
			RI5->RI5_ANO    := nAno
			RI5->RI5_NUMDOC := nNumero
			RI5->RI5_TIPDOC := cTpdoc
			RI5->RI5_DTATPO := dDoc
			RI5->RI5_DTAPUB := dPublic
			RI5->RI5_TXTCAB := ''
			RI5->RI5_TXTROD := ''
			RI5->RI5_STATUS := '2'
			RI5->RI5_TPARQ  := '2'
			RI5->(MsUnLock())
		Endif

		If nRadioOpc == 2 //valida SRA - matrículas
	       If cAusenc == .T.
			   _TABORI := "SR8"
       	   _CHAVE  := SRA->RA_FILIAL+SRA->RA_MAT+DTOS(CTOD(dInici))+Substring(cCombo,1,3)
			Else
   		   		_TABORI := "SRA"
				_CHAVE  := ""
			Endif
		Else
	   		_TABORI := "SQ3"
			_CHAVE  := ""
		EndIf
		If nRadioOpc == 2 //valida SRA - matrículas
	        //Grava tabela RI6-Itens de Documento - SRA Matrículas
		    VD210RI6({_TABORI,;                      	//RI6_TABORI
	    	       '',	;								   	//RI6_CODITE
	    	       SRA->RA_CIC,;                     	//RI6_CPF
	    	       SRA->RA_FILIAL,;                  	//RI6_FILMAT
	    	       SRA->RA_MAT,;							//RI6_MAT
	    	       cTpdoc,;								//RI6_TIPDOC
	    	       cClass,;								//RI6_CLASTP
	    	       '',;									//RI6_TXTITE
	    	       cTexto,;								//RI6_TXTHIS
	    	       '2',;									//RI6_STATUS
	    	       _CHAVE,; 								//RI6_CHAVE
	    	       nAno,;									//RI6_ANO
	    	       nNumero,;								//RI6_NUMDOC
	    	       date(),;								//RI6_DTATPO
	    	       dEfeito,;								//RI6_DTEFEI
	    	       '1',;									//RI6_CHVIDX
	    	       '',;                               //RI6_FILSUB
	    	       '',;									//RI6_MATSUB
	    	       '',;                               //RI6_FILCRG
	    	       ''})                               //RI6_CARGO
		Else
	        //Grava tabela RI6-Itens de Documento - SRA Matrículas
		    VD210RI6({_TABORI,;                      	//RI6_TABORI
	    	       '',	;								   	//RI6_CODITE
	    	       '',;		                     	//RI6_CPF
	    	       '',;       			           	//RI6_FILMAT
	    	       '',;									//RI6_MAT
	    	       cTpdoc,;								//RI6_TIPDOC
	    	       cClass,;								//RI6_CLASTP
	    	       '',;									//RI6_TXTITE
	    	       cTexto,;								//RI6_TXTHIS
	    	       '2',;									//RI6_STATUS
	    	       _CHAVE,; 								//RI6_CHAVE
	    	       nAno,;									//RI6_ANO
	    	       nNumero,;								//RI6_NUMDOC
	    	       date(),;								//RI6_DTATPO
	    	       dEfeito,;								//RI6_DTEFEI
	    	       '1',;									//RI6_CHVIDX
	    	       '',;                               //RI6_FILSUB
	    	       '',;									//RI6_MATSUB
	    	       SQ3->Q3_FILIAL,;                   //RI6_FILCRG
	    	       SQ3->Q3_CARGO})                    //RI6_CARGO
		EndIf
	Endif

	If  cParam == '4'
		If nRadioOpc == 2 //valida SRA - matrículas
			dbSelectArea("RI6")
			DbSetOrder(2)
			If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SRA->RA_CIC))
				RecLock("RI6",.F.)
				RI6_TXTHIS := cTexto
				RI6->(MsUnLock())
			Endif
		Else
			dbSelectArea("RI6")
			DbSetOrder(6)
			If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SQ3->Q3_CARGO))
				RecLock("RI6",.F.)
				RI6_TXTHIS := cTexto
				RI6->(MsUnLock())
			Endif
		EndIf
	Endif

	If  cParam == '5'
		If nRadioOpc == 2 //valida SRA - matrículas
			dbSelectArea("RI6")
			DbSetOrder(2)
			If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SRA->RA_CIC))
				RecLock("RI6",.F.)
				RI6_DTCANC := date()
				RI6_USCANC := cUserL
				DbDelete()
				RI6->(MsUnlock())
			Endif
		Else
			dbSelectArea("RI6")
			DbSetOrder(6)
			If  RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc+SQ3->Q3_CARGO))
				RecLock("RI6",.F.)
				RI6_DTCANC := date()
				RI6_USCANC := cUserL
				DbDelete()
				RI6->(MsUnlock())
			Endif
		Endif

		dbSelectArea("RI6")
		DbSetOrder(2)
		If  !RI6->(DbSeek(FWXFILIAL("RI6")+nAno+nNumero+cTpdoc))
			DbSetOrder(1)
			If  RI5->(DbSeek(FWXFILIAL("RI5")+nAno+nNumero+cTpdoc))
				RecLock("RI5",.F.)
				DbDelete()
				RI5->(MsUnlock())
			Endif
		Endif
	Endif

	End Transaction
Endif

RestArea(aArea)
Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210CSF
Verifica na tabela S101 se tipo de ausência =1 e habilita combo.

@sample 	VDFA210CSF(cClass)

@param		cClass - tipo de classifdicacao - S101

@return     T ou F

@author	    Nivia Ferreira
@since		31/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VDFA210CSF(cClass,nNumero,nAno)

Local aArea   := GetArea()
Local lRet    := .T.
Local lSubsTp	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

If Empty(cClass)
    MsgInfo(STR0024, '')												//'Informe a classificação.'
	Return(.F.)
Endif

If !Empty(nNumero) .And. !Empty(nAno)

	If Select("TRB") > 0
		TRB->( dbCloseArea())
	EndIf

	If lSubsTp
		cQuery  := "SELECT SUBSTRING(RCC_CONTEU,199,1) TIPO "
	Else
		cQuery  := "SELECT SUBSTR(RCC_CONTEU,199,1) TIPO"
	EndIf

	cQuery += " From "+RetSqlName("RCC")+" RCC "
	cQuery += " Where RCC.D_E_L_E_T_ = ' '"
	cQuery += " And RCC_FILIAL='" + FWXFILIAL("RCC")+ "' "
	cQuery += " AND RCC_CODIGO='S101' "
	If lSubsTp
		cQuery += " AND SUBSTRING(RCC_CONTEU,1,2)='"+ cClass +"'"
		cQuery += " AND SUBSTRING(RCC_CONTEU,199,1)='1'"
	Else
		cQuery += " AND SUBSTR(RCC_CONTEU,1,2)='"+ cClass +"'"
		cQuery += " AND SUBSTR(RCC_CONTEU,199,1)='1'"
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")

	If TRB->(!EOF())
	   cHabili:= .T.
	   cAusenc:= .T.
	Endif

	TRB->( dbCloseArea() )

Endif

RestArea(aArea)
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210AUS
Pesquisa as data de inicio do afastamento SR8.

@sample 	VDFA210AUS(cComb1)

@param		cComb1 - tipo de afastamento

@return    T ou F

@author	Nivia Ferreira
@since		31/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VDFA210AUS(cComb1)

Local aArea   := GetArea()
Local lRet    := .F.
Local cTitulo := STR0047 //"Inicio do Afastamento - "

Local bOk2    := {||lRet:=.T.,dInici:=cComb2,oDlg2:End()}
Local bCancel2:= {||oDlg2:End()}
Local oDlg2

Local oComb2
Local cComb2
Local aComb2:= {}

Local lSubsTp	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

If Select("TRB") > 0
	TRB->( dbCloseArea())
EndIf
//Monta combo com as datas de ausência
cQuery := " SELECT R8_DATAINI"
cQuery += " From "+RetSqlName("SR8")+" SR8 "
cQuery += " Where SR8.D_E_L_E_T_ = ' '"
cQuery += " And R8_FILIAL='" + SRA->RA_FILIAL+ "' "
cQuery += " AND R8_MAT='"+ SRA->RA_MAT + "' "

If lSubsTp
	cQuery  += " AND R8_TIPOAFA='"+ Substring(cComb1,1,3) +"'" "
Else
	cQuery  += " AND R8_TIPOAFA='"+ Substr(cComb1,1,3) +"'" "
EndIf
cQuery += " ORDER BY R8_DATAINI DESC "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
dbSelectArea("TRB")
If TRB->(!EOF())
	While  TRB->(!EOF())
		AAdd(aComb2, DTOC(STOD(TRB->R8_DATAINI)))
	  	TRB->( dbSkip() )
	Enddo

	Begin Sequence
	DEFINE MSDIALOG oDlg2 TITLE cTitulo+Alltrim(SRA->RA_NOME) FROM 9,0 TO 22,80 OF oMainWnd

	@ 33,005 SAY STR0043  OF oDlg2 PIXEL//"Data Incio da Ausência:"
	@ 33,080 MSCOMBOBOX oComb2 VAR cComb2 ITEMS aComb2 SIZE 50,8 OF oDlg2 PIXEL

    ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,bOk2,bCancel2)
	End Sequence
Endif

TRB->( dbCloseArea() )
RestArea(aArea)
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210VIS
Visualização dos Itens - RI6 por servidor

@sample 	VDFA210INC()

@param		cMat	Matricula do Servidor

@return	Nill

@author	Nivia Ferreira
@since		07/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA210VIS()
Local aArea   	:= GetArea()
Local cRet    	:= ''
Local cAlias  	:= GetNextAlias()
Local aSize		:= FWGetDialogSize( oMainWnd )
Local aComb  	:= {'Não','Sim'}
Local oGet1
Local oDlg
Local oComb1


Local aRotina  	:= MenuDef()	// Monta menu da Browse
Local cCadastro	:= STR0002 		//"Consulta/Certidao"
Local cFonte

Private cComb
Private oMark    	:= Nil
Private aQrytmp	:= {}

aQrytmp := VDFHQry('Não')
If nRadioOpc == 2 //valida SRA - matrículas
	cCadastro	:= STR0002 	//"Consulta/Certidao"
Else
	cCadastro	:= STR0059 	//"Consulta Atos e Portarias"
EndIf

//--------------------------------------------------------------
// Monta tela com lista de agendamentos do período
//--------------------------------------------------------------
oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , , , , , oMainWnd, .T. )

oLayer := FWLayer():New()
oLayer:Init( oDialog, .F.)

oLayer:AddLine( 'Linha', 100)
oLayer:AddColumn( 'Coluna', 100, .T., 'Linha' )
oLayer:AddWindow( 'Coluna', 'oDlgManut', cCadastro, 100, .F., .F., {||}, 'Linha' )
oDlgManut := oLayer:GetWinPanel( 'Coluna', 'oDlgManut', 'Linha' )

//----------------------------------------------------------
// Objetos para permitir selecionar um período de filtro
//----------------------------------------------------------
oPanelTop 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.10 )
oPanelTop:Align := CONTROL_ALIGN_TOP

oSay:= TSay():New( 03, 10, { || STR0048 }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Filial:'
If nRadioOpc == 2 //valida SRA - matrículas
	oSay:= TSay():New( 03, 80, { || STR0049 }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Matricula:'
	@ 20,030 MSGET oGet1 VAR SRA->RA_FILIAL  SIZE 30,8  OF oDlg PIXEL WHEN .F.
	@ 20,110 MSGET oGet1 VAR SRA->RA_MAT     SIZE 30,8  OF oDlg PIXEL WHEN .F.
	@ 20,143 MSGET oGet1 VAR SRA->RA_NOME    SIZE 100,8 OF oDlg PIXEL WHEN .F.
Else
	oSay:= TSay():New( 03, 80, { || STR0079 }, oPanelTop,,,,,,.T.,,, 50, 10 )	//'Cargo:'
	@ 20,110 MSGET oGet1 VAR SQ3->Q3_CARGO   SIZE 30,8  OF oDlg PIXEL WHEN .F.
	@ 20,143 MSGET oGet1 VAR SQ3->Q3_DESCSUM SIZE 150,8 OF oDlg PIXEL WHEN .F.
EndIf

oSay:= TSay():New( 18, 10, { || STR0050 }, oPanelTop,,,,,,.T.,,, 80, 20 ) 	//' Itens Cancelados?'
@ 37,110 MSCOMBOBOX oComb1 VAR cComb ITEMS aComb VALID VDF210TELA() SIZE 30,8 OF oDlg PIXEL

oPanelBot 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.90 )
oPanelBot:Align := CONTROL_ALIGN_BOTTOM

oMark:= FWFormBrowse():New()
oMark:SetOwner( oPanelBot )
oMark:AddMarkColumns( { || IIf( (cAlias)->RI6_OK == 1, "LBOK", "LBNO" ) })
oMark:SetDataQuery(.T.)
oMark:SetQuery( aQrytmp[1] )
oMark:SetAlias( cAlias )
oMark:SetColumns( aQrytmp[2] )
oMark:SetUseFilter( .T. )
oMark:DisableConfig()
oMark:DisableReport()
oMark:DisableDetails()
oMark:AddButton( STR0051, { || VDF210PROC(oMark,cAlias,cComb,'H'),oMark:Refresh(.T.)},,,, .F., 2 ) //"Consultar Historico"
If nRadioOpc == 2 //valida SRA - matrículas
	oMark:AddButton( STR0058, { || VDF210PROC(oMark,cAlias,cComb,'R'),oMark:Refresh(.T.)},,,, .F., 8 ) //"Certidão Funcional"
EndIf
oMark:AddButton( STR0052, { || oDialog:End() },,,, .F., 2 )	//'Sair'
oMark:aColumns[1]:bHeaderClick := {|| VD020MkAll( oMark ),oMark:Refresh(.T.) }
oMark:SetDoubleClick( {|| VD020MkOne( oMark ) } )
oMark:Activate()

oDialog:Activate( ,,,.T.,,, )

Return NIL



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF210PROC
Valida se há itens marcados na lista.
Monta a MarkBrowse da tabela RI6.

@sample 	VD020PROC(oBrowse, cAlias, cQuery)

@param	    oBrowse	Objeto do tipo FWBrowse.
			cAlias      Alias da tabela temporaria.
			cCombo      Nao - nao mostra itens excluidos/cancelados
            			 Sim - mostra itens excluidos/cancelados
            cTipo       H - HISTORICO
                         R - RELATORIO

@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF210PROC(oBrowse, cAlias, cItens, cTipo)
Local aArea		:= GetArea()
Local aAreaTmp	:= (cAlias)->(GetArea())
Local lRet			:= .F.
Local cClass  	:= ''
Local aColumns	:= {}
Local oMark1

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

While ( (cAlias)->(!Eof()) )
	If ( (cAlias)->RI6_OK == 1 )
		If 	cTipo == 'H'
	   		If !((cAlias)->RI6_CLASTP $ cClass)
	   			cClass += '/'+ (cAlias)->RI6_CLASTP
	   		EndIf
	   	Else
	   		If !((cAlias)->RI6_CLASTP $ cClass)
		   	    If !Empty(cClass)
		   	     	cClass += ","
		   	    Endif
		   		cClass += "'"+ (cAlias)->RI6_CLASTP + "'"
		   	Endif
		EndIf
	EndIf
	(cAlias)->(DbSkip())
EndDo

If 	cTipo == 'H' .And. !Empty(cClass) //Historico
	DbSelectArea("RI6")
	RI6->(dbSetOrder(5))

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	oMark1 := FWMarkBrowse():New()
	oMark1:SetAlias('RI6')
	oMark1:SetSemaphore(.T.)
	oMark1:AddLegend( "RI6_STATUS=='1'", "GREEN"  , STR0074)//'Gerado pelo Sistema'
	oMark1:AddLegend( "RI6_STATUS=='2'", "YELLOW" , STR0075)//'Criado Manualmente'
	oMark1:AddLegend( "RI6_STATUS=='3'", "Blue"   , STR0076)//'Alterado'
	oMark1:AddLegend( "RI6_STATUS=='4'", "Red"    , STR0056)//'Cancelado'
	If nRadioOpc == 2 //valida SRA - matrículas
		oMark1:SetDescription(STR0048 +Alltrim(SRA->RA_FILIAL)+'  '+STR0049 + Alltrim(SRA->RA_MAT)+' - '+ Alltrim(SRA->RA_NOME)) //'Filial: ', ' Matricula: '
	Else
		oMark1:SetDescription(STR0079 + Alltrim(SQ3->Q3_CARGO)+' - '+ Alltrim(SQ3->Q3_DESCSUM)) //'Cargo: ', ' Descricao '
	EndIf
	oMark1:SetFieldMark( 'RI6_OK' )
	//oMark1:SetAllMark( { || oMark1:AllMark() } )
	If nRadioOpc == 2 //valida SRA - matrículas
		oMark1:SetFilterDefault( "(RI6_CPF==SRA->RA_CIC .or. (RI6_FILMAT == SRA->RA_FILIAL .and. RI6_MAT==SRA->RA_MAT) .or. (RI6_FILSUB == SRA->RA_FILIAL .and. RI6_MATSUB==SRA->RA_MAT) ) .And. RI6_CLASTP $'"+ cClass +"' .And. RI6_ANO<> ' ' .And. RI6_NUMDOC<> '  '")
	Else
		oMark1:SetFilterDefault( "(RI6_CARGO==SQ3->Q3_CARGO) .And. RI6_CLASTP $'"+ cClass +"' .And. RI6_ANO<> ' ' .And. RI6_NUMDOC<> '  '")
		oMark1:SetOnlyFields( { 'RI6_CODITE','RI6_TABORI', 'RI6_CLASTP', 'RI6_DESCLA', 'RI6_DTEFEI', 'RI6_NUMDOC', 'RI6_ANO' } )
	EndIf
	oMark1:AddButton( STR0057, { || VD210EDIT(oMark1),oMark1:Refresh(.T.)},,,, .F., 7 ) //"Visualizar"
	oMark1:Activate()
	lRet := .T.
ElseIf cTipo == 'R' .And. !Empty(cClass)
	VDFR050(cClass)
Else
	MsgInfo(STR0063, '')	//'Selecione o tipo de de documento.'
Endif

RestArea( aAreaTmp )
RestArea( aArea )

VD020Atual( oBrowse, aQrytmp[1] )
oMark:Refresh()

Return NIL



//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210EDIT
Valida se há itens marcados na lista.

@sample 	VD020EDIT(oMark01)

@param	    oMark01	Objeto do tipo FWBrowse - RI6.

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210EDIT(oMark01)
Local aArea    := GetArea()
Local cMarca   := oMark01:Mark()

RI6->( dbGoTop() )
While !RI6->( EOF() )
	If 	oMark01:IsMark(cMarca)
   		VD210MOSTR()
	Endif
	RI6->( dbSkip() )
End

RestArea( aArea )
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210MOSTR
Abre o editor de texto com as informacoes publicadas.

@sample 	VD210EDIT()

@param

@return

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210MOSTR()
Local bCancel			:= {||oDlg:End()}
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords		:= {}
Local aRet           := {}
Local cTexto1        := ''
Local oTSmpEdit1
Local oTSmpEdit2

aRet    := VD210TIPO('V')
cTexto1 := aRet[1] + RI6->RI6_TXTHIS

Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0059 FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //'Consulta Atos/Portarias Publicado'

oTPanel1:= TPanel():New(10,10,"",oDlg,,,,,,100,100)
oTPanel1:Align := CONTROL_ALIGN_ALLCLIENT	//ALLCLIENT

//nTop, nLeft, nHeight, nWidth , cTitle, cText, nFormat, lShowOkButton, lShowCancelButton, oOwner
oTSmpEdit1 := tSimpEdit():New( , , , , "",  @cTexto1, 1, .F., .F.,oTPanel1)
oTSmpEdit1:oSimpEdit:lReadonly := .T.

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bCancel,bCancel)

End Sequence


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210TIPO
Acha o tipo do ato/portaria.

@sample 	VD210TIPO()

@param	    cTipo - V-visualizacao ou R-Relatorio

@author	Nivia Ferreira
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210TIPO(cTipo)
Local aArea    := GetArea()
Local cTexto   := ''
Local cQuery   := ''
Local aRet     := {}
Local lSubsTp	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

If Select("TRB") > 0
	TRB->( dbCloseArea())
EndIf
If 	lSubsTp
	cQuery  := " SELECT SUBSTRING(RCC_CONTEU,1,3) Codigo, "
 	cQuery  += "SUBSTRING(RCC_CONTEU,04,30) Descr,"
	cQuery  += "SUBSTRING(RCC_CONTEU,34,20) Tipo, "
	cQuery  += "SUBSTRING(RCC_CONTEU,54,05) Sigla "
Else
	cQuery  := " SELECT SUBSTR(RCC_CONTEU,1,3) Codigo, "
	cQuery  += "SUBSTR(RCC_CONTEU,04,30) Descr,"
	cQuery  += "SUBSTR(RCC_CONTEU,34,20) Tipo, "
	cQuery  += "SUBSTR(RCC_CONTEU,54,05) Sigla "
Endif

cQuery  += " FROM "+ RetSqlName( 'RCC' ) + " RCC "
cQuery  += " WHERE RCC.D_E_L_E_T_ = ' ' "
cQuery  += " AND RCC.RCC_CODIGO='S100' "

If 	lSubsTp
	cQuery  += " AND SUBSTRING(RCC_CONTEU,1,3)='"+ RI6->RI6_TIPDOC + "'"
Else
	cQuery  += " AND SUBSTR(RCC_CONTEU,1,3)='"+ RI6->RI6_TIPDOC + "'"
Endif

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

If	cTipo = 'V'
	cTexto := "<p align='center'>"
	cTexto += "<span style=' font-weight:600;'>"
	IF  RI6->RI6_STATUS == '4'
		cTexto += STR0060+ "<br /><br /><br />"  //CANCELADO
	Endif
	cTexto += Alltrim(TRB->TIPO)+" Nr "+RI6->RI6_NUMDOC+"/"+RI6->RI6_ANO+' - '+TRB->SIGLA
	cTexto += "<br /><br /><br /><br /><br /><br />"
Endif

AAdd( aRet, cTexto )
AAdd( aRet, TRB->TIPO )
AAdd( aRet, TRB->SIGLA)

TRB->( dbCloseArea() )

RestArea( aArea )
Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF210TELA
Seleciona todos os itens

@sample 	VDF210TELA()

@param

@return	Nil

@author	Nivia Ferreira
@since		01/07/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF210TELA()
Local xRet := .T.

aQrytmp := VDFHQry(cComb)
VD020Atual( oMark, aQrytmp[1] )

Return(xRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFHQry
Função para montar a consulta com os tipos de documentos do servidor.

@sample 	VDFHQry()

@param	    Sim - mostra itens excluidos/cancelados

@return	aRet 	Consulta e campos retornados.
			[1] cQuery  - Consulta no padrao SQL
			[2] aCampos - Estrutura dos campos da consulta

@author	Nivia Ferreira
@since		25/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFHQry(cTipo)
Local aArea	:= GetArea()
Local nJ      := 0
Local nI      := 0
Local aRet	   	:= {}
Local aCampos := {}
Local aColumns:= {}
Local cQuery  := ''
Local lSubsTp	:= "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

If lSubsTp
	cQuery  += " SELECT SUBSTRING(RCC.RCC_CONTEU,03,30) DESC_TP, 1 AS RI6_OK,RI6_CLASTP "
Else
	cQuery  += " SELECT SUBSTR(RCC.RCC_CONTEU,03,30) DESC_TP, 1 AS RI6_OK,RI6_CLASTP "
EndIf
cQuery  += " FROM "+ RetSqlName( 'RI6' ) + " RI6, " + RetSqlName( 'RCC' ) + " RCC "
cQuery  += " WHERE RI6.D_E_L_E_T_ = ' ' "
cQuery  += " AND RCC.D_E_L_E_T_ = ' ' "
cQuery  += " AND RI6.RI6_FILIAL='" + FWxFilial("RI6") +"'"
cQuery  += " AND RCC.RCC_CODIGO='S101' "
If nRadioOpc == 1 //Cargos
	cQuery  += " AND ( RI6.RI6_FILCRG='" + SQ3->Q3_FILIAL +"' AND RI6.RI6_CARGO='" + SQ3->Q3_CARGO +"') "
Else
	cQuery  += " AND (    ( RI6.RI6_FILMAT='" + SRA->RA_FILIAL +"' AND RI6.RI6_MAT='" + SRA->RA_MAT +"') "
	cQuery  += "       OR ( RI6.RI6_FILSUB='" + SRA->RA_FILIAL +"' AND RI6.RI6_MATSUB='" + SRA->RA_MAT +"') ) "
EndIf
If lSubsTp
	cQuery  += " AND SUBSTRING(RCC.RCC_CONTEU,01,02) =RI6_CLASTP"
Else
	cQuery  += " AND SUBSTR(RCC.RCC_CONTEU,01,02) =RI6_CLASTP"
EndIf
cQuery  += " AND RI6.RI6_DTATPO <> ' ' "
cQuery  += " AND RI6.RI6_ANO <> ' ' "

If cTipo == 'Sim'
   cQuery  += " AND RI6.RI6_STATUS IN('1','2','3','4') "
Else
   cQuery  += " AND RI6.RI6_STATUS IN('1','2','3') "
Endif

cQuery  += " GROUP BY RCC_CONTEU,RI6_CLASTP"
cQuery  += " ORDER BY RCC_CONTEU"


aCampos:={;
{STR0061,"RI6_CLASTP" , 02,0, "@!"},;
{STR0062,"DESC_TP"    , 30,0, "@!"}}

nJ := 1
For nI := 1 To Len(aCampos)

	AAdd( aColumns, FWBrwColumn():New() )
	aColumns[nJ]:SetData( &("{||" + aCampos[nI][2] + "}") )
	aColumns[nJ]:SetTitle( aCampos[nI][1] )
	aColumns[nJ]:SetSize( aCampos[nI][3] )
	aColumns[nJ]:SetDecimal( aCampos[nI][4] )
	aColumns[nJ]:SetPicture( aCampos[nI][5] )

	nJ++
Next nI

AAdd( aRet, cQuery )
AAdd( aRet, aColumns )

RestArea(aArea)
Return (aRet)



//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFA210MAN
Monta a MarkBrowse da tabela RI6 com todos os itens nao publicados, por filial/matricula.

@sample 	VDFA210MAN()

@param

@author	Nivia Ferreira
@since		13/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFA210MAN()
Local aArea   	:= GetArea()
Local aRotina  	:= MenuDef()	// Monta menu da Browse

Private cCtlMenu 	:= 'VDFA210MAN'
Private oMark02 	:= Nil

oMark02 := FWMarkBrowse():New()
oMark02:SetAlias('RI6')
If nRadioOpc == 1 //Cargos
	oMark02:SetOnlyFields( { 'RI6_CARGO','RI6_CODITE', 'RI6_TIPDOC', 'RI6_CLASTP','RI6_DESCLA' } )
Else
	oMark02:SetOnlyFields( { 'RI6_MAT','RI6_CODITE', 'RI6_TIPDOC', 'RI6_CLASTP','RI6_DESCLA','RI6_DESCLA' } )
EndIf
oMark02:SetSemaphore(.T.)
oMark02:AddLegend( "RI6_STATUS=='1'", "GREEN"  , STR0074)//'Gerado pelo Sistema'
oMark02:AddLegend( "RI6_STATUS=='2'", "YELLOW" , STR0075)//'Criado Manualmente'
oMark02:AddLegend( "RI6_STATUS=='3'", "Blue"   , STR0076)//'Alterado'
oMark02:AddLegend( "RI6_STATUS=='4'", "Red"    , STR0056)//'Cancelado'
oMark02:SetDescription( STR0070 )//'Manutenção dos Itens'
oMark02:SetFieldMark( 'RI6_OK' )
oMark02:SetAllMark( { || oMark01:AllMark() } )
If nRadioOpc == 1 //Cargos
	oMark02:SetFilterDefault( "RI6_FILCRG== '"+ SQ3->Q3_FILIAL +"' .And. RI6_CARGO== '"+ SQ3->Q3_CARGO+ "'  .And. RI6_DTATPO==' ' .And. RI6_ANO==' '  .And. RI6_NUMDOC==' ' " )
Else
	oMark02:SetFilterDefault( "RI6_FILMAT== '"+ SRA->RA_FILIAL +"' .And. RI6_MAT== '"  + SRA->RA_MAT+ "'  .And. RI6_DTATPO==' ' .And. RI6_ANO==' '  .And. RI6_NUMDOC==' ' " )
EndIf
oMark02:AddButton( STR0009,{ || VD210ATU('E'),oMark02:Refresh(.T.)},,,, .F., 5 ) //"Excluir Item Publ"
oMark02:AddButton( STR0069,{ || VD210ATU('R'),oMark02:Refresh(.T.)},,,, .F., 3 ) //"Reativar Item Publ"
oMark02:AddButton( STR0029,{ || VD210ATU('A'),oMark02:Refresh(.T.)},,,, .F., 4 ) //"Alterar Item Publ"
oMark02:Activate()

RestArea( aArea )
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD210ATU
Excluir /Reativar / Alterar documento.

@sample 	VD210EXC()

@param	   cTipo = R - reativar  E - Excluir  A - Alterar

@author	Nivia Ferreira
@since		13/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD210ATU(cTipo)
Local cMarca 	:= oMark02:Mark()
Local cItem	  	:= ''

While !RI6->( EOF() )

	If oMark02:IsMark(cMarca)
		If 	cTipo == 'E' .And. RI6->RI6_STATUS <> '4' //Excluir
			RecLock("RI6",.F.)
			RI6->RI6_DTCANC := date()
			RI6->RI6_USCANC := cUserL
			RI6->RI6_OK     := ''
			RI6->RI6_STATUS := '4'
			RI6->(MsUnlock())
		Endif

		If 	cTipo == 'R' .And. RI6->RI6_STATUS = '4'//Reativar
			RecLock("RI6",.F.)
			RI6->RI6_DTCANC := nil
			RI6->RI6_USCANC := ''
			RI6->RI6_OK     := ''
			RI6->RI6_STATUS := '1'
			RI6->(MsUnlock())
		Endif

		If 	cTipo == 'A' .And. RI6->RI6_STATUS <> '4' //Alterar
			cItem := RI6->RI6_TXTHIS
			VDFA210EDT(RI6->RI6_TIPDOC,RI6->RI6_CLASTP,'','','2','')
		Endif
	EndIf
	RI6->(DbSkip())
EndDo

Return
