#INCLUDE "Protheus.ch"
#INCLUDE "tmsa450.ch"
#INCLUDE "FWMVCDEF.CH"

Static lRotaInt := .F. //SuperGetMV("MV_ROTAINT",,.F.)  Rota Inteligente
Static lIntTPR  := SuperGetMV("MV_ROTAINT",,.F.)  .And. AliasInDic("DMS") //Integração TPR	

//-----------------------------------------------------------------------------------------------------------
/* Browse da rotina de Cadastro de Sequencia de Endereco
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	14/11/2013
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Function TMSA450(aRotAuto,nOpcAuto)

Local oMBrowse		:= Nil
Local aAutoCab		:= {}
Local l450Auto		:= aRotAuto <> NIL
Local cRoteiri      := ""

Private aRotina	:= MenuDef()

Default nOpcAuto := 3

If lIntTPR .And. FindFunction('TMSROTEIRI')
	cRoteiri:= TMSROTEIRI() 
	lIntTPR:= cRoteiri == '2'   //1-Maplink, 2-TPR
EndIf

If l450Auto
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), "DUL", nOpcAuto, { { "MdFieldDUL", aAutoCab }  } )  //Chamada da rotina automatica através do MVC
Else
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================

	oMBrowse:= FWMBrowse():New()
	oMBrowse:SetAlias("DUL")
	oMBrowse:SetDescription( OemToAnsi( STR0001 ) )
	oMBrowse:Activate()

EndIf

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Sequencia de Endereco
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		13/11/2012
@return 	oModel - Modelo de Dados */
//===========================================================================================================

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDUL	:= FwFormStruct( 1, "DUL" )

oModel	:= MpFormModel():New( "TMSA450", /*bPre*/, { |oModel| PosVldMdl( oModel ) },  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )

oModel:AddFields( "MdFieldDUL", Nil, oStruDUL )

oModel:SetPrimaryKey( { "DUL_FILIAL", "DUL_SEQEND" } )

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Sequencia de Endereco
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel	:= FwLoadModel( "TMSA450" )
Local oView		:= Nil
Local oStruDUL	:= FwFormStruct( 2, "DUL" )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "Field"	, 100 )

oView:AddField( "VwFieldDUL", oStruDUL, "MdFieldDUL"	)

oView:SetOwnerView( "VwFieldDUL"	, "Field"	)

Return( oView )

//===========================================================================================================
/* PÓS validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	lRet */
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet		    := .T.
Local aArea		:= GetArea()
Local lTm450Tok 	:= ExistBlock("TM450TOK")

DUE->(DbSetOrder(1))
DUE->(MsSeek(xFilial('DUE')+M->DUL_CODSOL) )

If DUE->DUE_TIPCOL == '2'  .And. Empty(M->DUL_CEP)
	Help('',1,"OBRIGAT2",,RetTitle('DUE_CEP'),04,01)
	lRet := .F.
EndIf

If lTm450Tok
	lRet := ExecBlock("TM450TOK",.F.,.F., )
	If ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Gravação do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet	:= .T.
Local nOpcx	:= oMdl:GetOperation()
Local aArea    := GetArea()
Local oMdlDAR  := Nil

//-- Atualizacao do movimento de viagem
If nOpcx == MODEL_OPERATION_UPDATE 

	Begin Transaction
          If M->DUL_CEP <> DUL->DUL_CEP
			TmsCEPDUD(M->DUL_CEP,,,DUL->DUL_CODSOL,DUL->DUL_SEQEND)
          EndIf
	End Transaction

ElseIf nOpcx == MODEL_OPERATION_DELETE
     If lRotaInt .Or. lIntTPR   
          dbSelectArea("DAR")
          DAR->(dbSetOrder(1))
          If DAR->(MsSeek(xFilial("DAR")+DUL->DUL_FILIAL+"DUL"+DUL->DUL_SEQEND))
               oMdlDAR := FWLoadModel( 'TMSAO15' )
               oMdlDAR :SetOperation( MODEL_OPERATION_DELETE )
               oMdlDAR :Activate()
               lRet := oMdlDAR:VldData()
               
               If lRet
                    lRet := oMdlDAR:CommitData()
               EndIf
          
               oMdlDAR:DeActivate()
          EndIf
     EndIf     
EndIf

lRet := FwFormCommit( oMdl )

If lRet .And. nOpcx == MODEL_OPERATION_UPDATE .Or. nOpcx == MODEL_OPERATION_INSERT
	If (lRotaInt .Or. lIntTPR) .And. ExistFunc("TMSIntRot")  //Integração Rota Inteligente
		TMSIntRot("DUL",DUL->(Recno())) 
	EndIf
EndIf

RestArea( aArea )
Return( lRet )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Sequencia de Endereco
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0003		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0004		,"VIEWDEF.TMSA450"		,0 , 2 },;  		//"Visualizar"
							{ STR0005		,"VIEWDEF.TMSA450"		,0 , 3 },;  		//"Incluir"
							{ STR0006		,"VIEWDEF.TMSA450"		,0 , 4 },;  		//"Alterar"
							{ STR0007		,"VIEWDEF.TMSA450"		,0 , 5 }}           //"Excluir"

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA450Vld³ Autor ³ Eduardo de Souza      ³ Data ³ 05/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA450Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA450Vld()

Local cCampo := ReadVar()
Local lRet   := .T.

If cCampo $ "M->DUL_CODCLI;M->DUL_LOJCLI"
          If !Empty(M->DUL_CODCLI) .And. !Empty(M->DUL_LOJCLI) 
               If ( lRet := ExistCpo("SA1",M->DUL_CODCLI+AllTrim(M->DUL_LOJCLI) ,1) )
                    If !Empty(M->DUL_CODCLI) .And. !Empty(M->DUL_LOJCLI)
                         M->DUL_DDD := SA1->A1_DDD
                         M->DUL_TEL := SA1->A1_TEL
                         M->DUL_EST := SA1->A1_EST
                         If DUL->(FieldPos("DUL_CDRDES")) > 0
                              M->DUL_CDRDES := SA1->A1_CDRDES
                              M->DUL_MUN    := Padr(Posicione("DUY",1,xFilial("DUY")+M->DUL_CDRDES,"DUY_DESCRI"),Len(DUL->DUL_MUN))
                         EndIf

                         //-- Gatilha o primeiro Solicitante que encontrar na DUE
                         If Empty(M->DUL_CODSOL)
                              DUE->(DbSetOrder(3))
                              If DUE->(MsSeek(xFilial('DUE')+M->DUL_CODCLI+M->DUL_LOJCLI) )
                                   M->DUL_CODSOL := DUE->DUE_CODSOL
                              EndIf
                         Else
                              DUE->(DbSetOrder(1))
                              If DUE->(MsSeek(xFilial('DUE')+M->DUL_CODSOL) ) .And. DUE->DUE_CODCLI+DUE->DUE_LOJCLI <> M->DUL_CODCLI+M->DUL_LOJCLI
                                   Help(" ",1,"TMSA45004") // "O Solicitante informado não está relacionado a este Codigo de Cliente/Loja."
                                   lRet:= .F.
                              EndIf
                         EndIf
                    EndIf
               EndIf
          Else
               M->DUL_DDD    := Space(Len(DUL->DUL_DDD))
               M->DUL_TEL    := Space(Len(DUL->DUL_TEL))
               M->DUL_LOJCLI := Space(Len(DUL->DUL_LOJCLI))
          EndIf
ElseIf cCampo $ "M->DUL_CODSOL"
	If ( lRet := ExistCpo("DUE",M->DUL_CODSOL) )    
			DUE->(DbSetOrder(1))
			DUE->(MsSeek(xFilial('DUE')+M->DUL_CODSOL) )
			If Empty(M->DUL_CODCLI) .Or. Empty(M->DUL_LOJCLI)
				M->DUL_CODCLI := DUE->DUE_CODCLI
				M->DUL_LOJCLI := DUE->DUE_LOJCLI
			Else
				If DUE->DUE_CODCLI+DUE->DUE_LOJCLI <> M->DUL_CODCLI+M->DUL_LOJCLI
					Help(" ",1,"TMSA45004") // "O Solicitante informado não está relacionado a este Codigo de Cliente/Loja."
					lRet:= .F.
				EndIf
			EndIf	
			M->DUL_EST    := DUE->DUE_EST 			
			If DUL->(FieldPos("DUL_CDRDES")) > 0
				M->DUL_CDRDES := DUE->DUE_CDRSOL
				M->DUL_MUN    := Padr(Posicione("DUY",1,xFilial("DUY")+M->DUL_CDRDES,"DUY_DESCRI"),Len(DUL->DUL_MUN))
			EndIf
	EndIf
ElseIf cCampo == "M->DUL_CDRDES"
	M->DUL_MUN := Padr(Posicione("DUY",1,xFilial("DUY")+M->DUL_CDRDES,"DUY_DESCRI"),Len(DUL->DUL_MUN))
	       
	If Empty(M->DUL_MUN) //Valida codigo da regiao
		Help(" ",1,"REGNOIS")
		lRet := .F.
	Else
		M->DUL_EST := DUY->DUY_EST
	EndIf
ElseIf cCampo == "M->DUL_CODMUN"

	If !Empty(M->DUL_CODMUN) .AND. !Empty(M->DUL_EST)
                M->DUL_MUN := Padr(Posicione("CC2",1,xFilial("CC2")+M->DUL_EST+M->DUL_CODMUN,"CC2_MUN"),Len(DUL->DUL_MUN))
	EndIf
	
ElseIf cCampo $ "M->DUL_CODRED;M->DUL_LOJRED"
	If !Empty(M->DUL_CODRED)
		If ( lRet := ExistCpo("SA1",M->DUL_CODRED+AllTrim(M->DUL_LOJRED),1) )
			If !IsInCallStack("TMSAE80Inc") .And. !Empty(M->DUL_CODRED) .And. !Empty(M->DUL_LOJRED)
				SA1->( dbSetOrder ( 1 ) )
				If SA1->( dbSeek ( xFilial("SA1")+M->DUL_CODRED+M->DUL_LOJRED ) )
					M->DUL_NOMRED  := SA1->A1_NOME
					M->DUL_INSCR   := SA1->A1_INSCR
					M->DUL_CGC     := SA1->A1_CGC
					M->DUL_END     := SA1->A1_END
					M->DUL_BAIRRO  := SA1->A1_BAIRRO
					M->DUL_MUN     := SA1->A1_MUN
					M->DUL_EST     := SA1->A1_EST
					M->DUL_CEP     := SA1->A1_CEP
					M->DUL_CDRDES  := SA1->A1_CDRDES
				EndIf
			EndIf
		EndIf
	Else
		M->DUL_NOMRED  := CriaVar("A1_NOME",.F.) 
		M->DUL_INSCR   := CriaVar("A1_INSCR",.F.)
		M->DUL_CGC     := CriaVar("A1_CGC",.F.)
		M->DUL_END     := CriaVar("A1_END",.F.)
		M->DUL_BAIRRO  := CriaVar("A1_BAIRRO",.F.)
		M->DUL_MUN     := CriaVar("A1_MUN",.F.)
		M->DUL_EST     := CriaVar("A1_EST",.F.)
		M->DUL_CEP     := CriaVar("A1_CEP",.F.)
		M->DUL_CDRDES  := CriaVar("A1_CDRDES",.F.)
	EndIf
ElseIf cCampo == "M->DUL_CGC"
	                                                     
	//Nao possui campo para distinguir de Pessoa Juridica ou Fisica. Permite CNPJ ou CPF.
	lRet := CGC(M->DUL_CGC)
EndIf

Return lRet 


/*
====================================================================================================
/{Protheus.doc} Tmsa450Seq
//TODO Rotina utilizada para informar a sequencia de endereço no cadastro de notas fiscais,
         essa rotina foi desenvolvida para que seja permitido o envio de integração EAI do TMSA450
@author  tiago.dsantos
@since   09/01/2017
@version 1.000
@param   cAlias, characters, descricao
@param   cTipCli, characters, descricao
@type    function
/===================================================================================================
*/
Function Tmsa450Seq(cAlias)
Local aAreaDUL  := DUL->(GetArea())
Local cCliente  := ""
Local cLoja     := ""
Local cCodSol   := ""
Local lRet      := .F.
Local cCampo    := ReadVar()

Default cAlias  := "DUL"

     VAR_IXB := ""

     Do Case
          Case cCampo == "M->DTC_SQEREM" //| Remetente: Nota Fiscal Cliente
               cCliente  := M->DTC_CLIREM
               cLoja     := M->DTC_LOJREM

          Case cCampo == "M->DTC_SQEDES" //| Destinatario
               cCliente  := M->DTC_CLIDES
               cLoja     := M->DTC_LOJDES

          Case cCampo == "M->DF1_SQEREM" .And. Funname() == "TMSAF05" //| Remetente: Agendamento
               cCliente  := GDFieldGet("DF1_CLIREM",n)
               cLoja     := GDFieldGet("DF1_LOJREM",n)
          
          Case cCampo == "M->DF1_SQEDES" .And. Funname() == "TMSAF05" //| Destinatário: Agendamento
               cCliente  := GDFieldGet("DF1_CLIDES",n)
               cLoja     := GDFieldGet("DF1_LOJDES",n)
          
          Case cCampo == "M->DT6_SQEDES" //- Destinatário do Documento Transporte
          		 cCliente := M->DT6_CLIDES
          		 cLoja	  := M->DT6_LOJDES

     EndCase

     If (lRet:= TMSA450SQE(cAlias,cCodSol,cCliente,cLoja))
          VAR_IXB := DUL->DUL_SEQEND
     EndIf

     RestArea( aAreaDUL )

Return( lRet )


/*
==========================================================================================
/{Protheus.doc} TMSA450SQE
//TODO Descrição auto-gerada.
@author  tiago.dsantos
@since   09/01/2017
@version undefined
@param   cAlias, characters, descricao
@param   cCodSol, characters, descricao
@param   cCliente, characters, descricao
@param   cLoja, characters, descricao
@type    function
==========================================================================================
/*/
Static Function TMSA450SQE(cAlias,cCodSol,cCliente,cLoja)
Local aRotOld   := aClone(aRotina)
Local cFiltro1  := ""
Local aCampos   := {}
Local aRotina   := {}

Default cCodSol := " "
Default cAlias  := "DUL"
Default cCliente:= " "
Default cLoja  := " " 

Private cCadastro := STR0001 //"Endereco de Solicitante e Cliente"
Private nOpcSel := 0

     If ValType(cAlias) <> "C"
          cAlias := "DUL"
     EndIf
     
     SaveInter()

     //+---------------------------------------------------
     //| Define os campos do Browse.                       
     //+---------------------------------------------------
     AAdd(aCampos, "DUL_SEQEND")
     AAdd(aCampos, "DUL_NOMRED")
     AAdd(aCampos, "DUL_END")
     AAdd(aCampos, "DUL_BAIRRO")
     AAdd(aCampos, "DUL_MUN")
     AAdd(aCampos, "DUL_EST")

     aRotina := { { STR0004 ,"TMSA450Mnt",0,2},;       //"Visualizar"
                  { STR0005 ,"TMSA450Mnt",0,3},;       //"Incluir"
                  { STR0006 ,"TMSA450Mnt",0,4},;       //"Alterar"
                  { STR0007 ,"TMSA450Mnt",0,5},;       //"Excluir"
                  { STR0008 ,"TMSConfSel",0,2,,,.T.} } //"Confirmar"

     If !Empty(cCliente) .And. !Empty(cLoja)
          DUL->(DbSetOrder(2))
          cFiltro1 := '"'+xFilial("DUL")+cCliente+cLoja+'"''
     ElseIf !Empty(cCodSol)
          cCodsol := &('M->'+cAlias+'_CODSOL')
          DUL->(DbSetOrder(3))
          cFiltro1 := '"'+xFilial("DUL")+cCodSol+'"''
     EndIf

     
     MaWndBrowse(0,0,300,662,cCadastro,"DUL",aCampos,aRotina,,cFiltro1,cFiltro1,.T.)

     aRotina := aClone(aRotOld)
     
     RestInter()

Return( nOpcSel == 1 )


/*
================================================================================
/{Protheus.doc} TMSASolMnt
//TODO Compatibilização de chamada do menu em MVC
@author  tiago.dsantos
@since   09/01/2017
@version undefined
@param   cAlias, characters, descricao
@param   nReg, numeric, descricao
@param   nOpcx, numeric, descricao
@type    function
================================================================================
*/
Function TMSA450Mnt(cAlias,nReg,nOpcx)
     Do Case
          Case nOpcx == 1
               FWExecView (, "TMSA450" , MODEL_OPERATION_VIEW   , ,{|| .T. }, , , , , , , )   
          Case nOpcx == 2
               FWExecView (, "TMSA450" , MODEL_OPERATION_INSERT , ,{|| .T. }, , , , , , , )   
          Case nOpcx == 3
               FWExecView (, "TMSA450" , MODEL_OPERATION_UPDATE , ,{|| .T. }, , , , , , , )   
          Case nOpcx == 4
               FWExecView (, "TMSA450" , MODEL_OPERATION_DELETE , ,{|| .T. }, , , , , , , )   
     EndCase

Return( Nil )

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author tiago.dsantos
@since 15/09/2016
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
=========================================================================================================
/*/
Static Function IntegDef(cXml,nType,cTypeMsg)
Local  aResult := {}
       aResult := TMSI450(cXml,nType,cTypeMsg)
Return aResult
