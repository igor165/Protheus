#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA850.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEA850    Ё Autor Ё Leandro Drumond       	      Ё Data Ё 18/06/12 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Manutencao de Complementos Trabalhistas                      			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA850()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Cecilia C.  Ё 19/05/14 ЁTPPCSB          ЁIncluido o fonte da 11 para a 12 e efetuadaЁ╠╠
╠╠Ё             Ё          Ё                Ёa limpeza.                                 Ё╠╠
╠╠Ё Sidney O.   Ё 29/07/14 ЁTPVN08          ЁAlterada a funcao Gp850VlPer. Ajuste na    Ё╠╠
╠╠Ё             Ё          Ё                Ёvalidacao das datas.                       Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/

Function GPEA850()

Local oMBrowse
Local cFiltraRh
   
oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("RF1")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'Cadastro de Complementos Trabalhistas'

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEA850","RF1","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructRF1

// Criacao do Objeto de Modelagem de dados da tabela RF1 //
oModel     := MPFormModel():New("GPEA850", NIL, NIL, {|oModel| GPEA850Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

// Estrutura de campos do Model //
oStructRF1 := FWFormStruct(1, "RF1")
oStructRF1:RemoveField("RF1_FILIAL")

oModel:AddFields("GPEA850_RF1", NIL, oStructRF1)
oModel:SetPrimaryKey({"RF1_IDCMPL"})

oModel:GetModel( "GPEA850_RF1" ):SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё       
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructRF1

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA850")	
oStructRF1 := FWFormStruct(2, "RF1")

oStructRF1:RemoveField("RF1_FILIAL")

oView:SetModel(oModel)
oView:AddField("GPEA850_RF1", oStructRF1)

oView:CreateHorizontalBox("FIELDS", 100)

oView:SetOwnerView("GPEA850_RF1", "FIELDS")
	
Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEA850Commit  ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGravacao das informacoes com as validacoes pertinentes      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPEA850Commit(oModel)

Local nOperation

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

	If GP850ValPer(oModel)
      	FWFormCommit(oModel)
    EndIf   

// Tratamento de exclusЦo
ElseIf nOperation == MODEL_OPERATION_DELETE
	
	If Gpa850VldDel(oModel)
		FWFormCommit(oModel)
	EndIf

EndIf
	
Return( .T. )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpa850VldDel   ЁAutorЁ  Leandro Drumond  Ё Data Ё27/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida delecao dos registros							    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpa850VldDel(oModel)
Local aArea		:= GetArea()
Local cIdCmpl	:= ''
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local lRet 		:= .T.

cIdCmpl := oRF1Struct:GetValue( "RF1_IDCMPL" )

DbSelectArea('RFC')
DbSetOrder(RetOrder('RFC','RFC_IDCMPL'))

If DbSeek(cIdCmpl)
	lRet := .F.
	MsgAlert(STR0008) //"Existem registros de RRA gerados para este complemento. ExclusЦo nЦo poderА ser realizada."
EndIf

RestArea(aArea)

Return lRet

/*                                	
зддддддддддбддддддддддддддбдддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp850VlPer	  ЁAutorЁ Equipe Inovacao RH  Ё Data Ё09/08/2013Ё
цддддддддддеддддддддддддддадддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida intervalo de periodo                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gp850VlPer(dDataIni, dDataFim)
Local lRet := .T.

If !Empty(dDataIni)           
    If Len(Alltrim(dDataIni)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataIni,2)) < 1 .OR. Val(Left(dDataIni,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf
EndIf

If !Empty(dDataFim)
    If Len(Alltrim(dDataFim)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataFim,2)) < 1 .OR. Val(Left(dDataFim,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf

    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        lRet := .F.
    EndIf                
EndIf

Return(lRet)
  
/*                                	
зддддддддддбдддддддддддддддбдддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEA850ValPer ЁAutorЁ Equipe Inovacao RH Ё Data Ё12/08/2013Ё
цддддддддддедддддддддддддддадддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida informacoes de periodo inicial e final               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GP850ValPer(oModel)
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local dDataIni := oRF1Struct:GetValue( "RF1_AAMMI" ) 
Local dDataFim := oRF1Struct:GetValue( "RF1_AAMMF" ) 
Local lRet := .T.

If !Empty(dDataIni) .And. !Empty(dDataFim) 
    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        MsgAlert( OemToAnsi( STR0010 ), OemToAnsi( STR0009 ) )  
        lRet := .F.
    EndIf
EndIf                             
Return( lRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA850" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA850" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA850" 		OPERATION 4 ACCESS 0				//'Alterar'  
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.GPEA850" 		OPERATION 5 ACCESS 0				//'Excluir'
	ADD OPTION aRotina TITLE STR0007  ACTION 'VIEWDEF.GPEA850'		OPERATION 9 ACCESS 0 				//"Copiar" 

Return aRotina     

