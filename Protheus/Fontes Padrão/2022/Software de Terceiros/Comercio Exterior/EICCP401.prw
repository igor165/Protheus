#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EEC.CH"
#include 'EICCP401.CH'
#Include "TOPCONN.CH"

/*
Programa   : EICCP4010
Objetivo   : Rotina - Integração do Catalogo de Produtos
Retorno    : Nil
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function EICCP401(aCapaAuto,nOpcAuto)
Local lRet := .T.
Local aArea := GetArea()
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1
Local cModoAcEK9	:= FWModeAccess("EK9",3)
Local cModoAcEKA	:= FWModeAccess("EKA",3)
Local cModoAcEKB	:= FWModeAccess("EKB",3)
Local cModoAcEKD	:= FWModeAccess("EKD",3)
Local cModoAcEKE	:= FWModeAccess("EKE",3)
Local cModoAcEKF	:= FWModeAccess("EKF",3)
Local cModoAcSB1	:= FWModeAccess("SB1",3)
Local cModoAcSA2	:= FWModeAccess("SA2",3)

Private aRotina
Private lCP401Auto := ValType(aCapaAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private lMultiFil
Private lEkbPAis     :=EKB->(FieldPos("EKB_PAIS"))>0
Private lEKFVincFB   :=EKF->(FieldPos("EKF_VINCFB"))>0 

aCores :={{ "EKD_STATUS == '2' "	,"BR_AMARELO"  ,STR0008 },; //"Pendente Registro"
          { "EKD_STATUS == '1' "	,"ENABLE"      ,STR0009 },; //"Registrado"
          { "EKD_STATUS == '3' "	,"BR_VERMELHO" ,STR0010 },; //"Obsoleto"
          { "EKD_STATUS == '4' "	,"BR_PRETO"    ,STR0025 },; //"Falha de Integração"
          { "EKD_STATUS == '5' " ,"BR_AZUL"     ,STR0027 }}  //"Registrado (pendente: fabricante/país)"

lMultiFil      := VerSenha(115) .And. cModoAcEK9 == "C" .And. cModoAcSB1 == "E" .And. cModoAcSA2 == "E"

If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
   EasyHelp(STR0018,STR0014) //"O Modo de compatilhamento está diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "###Atenção
Else

	If !lCP401Auto
		oBrowse := FWMBrowse():New()                                 //Instanciando a Classe
		oBrowse:SetAlias("EKD")                                      //Informando o Alias 
		oBrowse:SetMenuDef("EICCP401")                               //Nome do fonte do MenuDef
		oBrowse:SetDescription(STR0007)                              //"Integração do Catalogo de Produtos" //Descrição a ser apresentada no Browse   

		For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
		
		oBrowse:SetAttach( .T. )                                     //Habilita a exibição de visões e gráficos
		oBrowse:SetViewsDefault(GetVisions())                        //Configura as visões padrão
		oBrowse:ForceQuitButton()                                    //Força a exibição do botão fechar o browse para fechar a tela                                                              
		oBrowse:Activate()                                           //Ativa o Browse 
	Else
		aRotina	:= MenuDef()
		INCLUI := nOpcAuto == INCLUIR                                //Definições de WHEN dos campos
		ALTERA := nOpcAuto == ALTERAR
		EXCLUI := nOpcAuto == EXCLUIR
		If ALTERA .Or. EXCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) == 0
				EasyHelp(STR0019,STR0014)//"A Operação de Exclusão ou Alteração deve conter a Versão do Catálogo."####"Atenção"
				lRet := .F.
			EndIf
		EndIf
		If INCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) > 0
				EasyHelp(STR0020,STR0014)//"Na Operação de Inclusão não é permitido informar o campo de Versão do Catálogo."###"Atenção"
				lRet := .F.
			EndIf
		EndIf
		If lRet
			EasyMbAuto(nOpcAuto,aCapaAuto,"EKD",,,ModelDef(),{{"EKDMASTER",aCapaAuto}})
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aRotina
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001 , "AxPesqui"			, 0, 1, 0, NIL } )	//'Pesquisar'
aAdd( aRotina, { STR0002 , 'VIEWDEF.EICCP401', 0, 2, 0, NIL } )	//'Visualizar'
aAdd( aRotina, { STR0003 , 'VIEWDEF.EICCP401', 0, 3, 0, NIL } )	//'Incluir'
aAdd( aRotina, { STR0026 , 'CP401Canc'	      , 0, 4, 0, NIL } )	//'Tornar Obsoleto'
aAdd( aRotina, { STR0005 , 'VIEWDEF.EICCP401', 0, 5, 0, NIL } )	//'Excluir'
aAdd( aRotina, { STR0006 , 'CP401Legen'		, 0, 1, 0, NIL } )	//'Legenda'

Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ModelDef()
Local oStruEKD			:= FWFormStruct( 1, "EKD", , /*lViewUsado*/ )
Local oStruEKE 		:= FWFormStruct( 1, "EKE", , /*lViewUsado*/ )
Local oStruEKF			:= FWFormStruct( 1, "EKF", , /*lViewUsado*/ )
Local oStruEKI			:= FWFormStruct( 1, "EKI", , /*lViewUsado*/ )
Local oModel			// Modelo de dados que será construído	
Local bPosValidacao	:= {|oModel| CP401POSVL(oModel)}
Local bCommit			:= {|oModel| CP401COMMIT(oModel)}
Local oMdlEvent      := CP401EV():New()
// Criação do Modelo
oModel := MPFormModel():New( "EICCP401", /*bPreValidacao*/, bPosValidacao, bCommit,  )
oModel:AddFields("EKDMASTER", /*cOwner*/ ,oStruEKD )                                               //Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:SetPrimaryKey( { "EKD_FILIAL", "EKD_COD_I" , "EKD_VERSAO"} )                                //Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0007)                                                                     //"Integração do Catalogo de Produtos
oModel:GetModel("EKDMASTER"):SetDescription(STR0007)                                               //Adiciona a descrição do Componente do Modelo de Dados "Integração do Catalogo de Produtos"

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Relação de Produtos
oModel:AddGrid("EKEDETAIL","EKDMASTER", oStruEKE, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKEDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum PRODUTO //MFR 11/02/2022 OSSME-6595
oModel:GetModel("EKEDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKEDETAIL"):SetNoInsertLine(.T.)
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Fabricantes
oModel:AddGrid("EKFDETAIL","EKDMASTER", oStruEKF, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKFDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Fabricante
oModel:GetModel("EKFDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKFDETAIL"):SetNoInsertLine(.T.)
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Atributos
oModel:AddGrid("EKIDETAIL","EKDMASTER", oStruEKI, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKIDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Atributo
oModel:GetModel("EKIDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKIDETAIL"):SetNoInsertLine(.T.)
oStruEKI:RemoveField("EKI_COD_I")
oStruEKI:RemoveField("EKI_VERSAO")

//Modelo de relação entre Capa - Produto Referencia(EK9) e detalhe Relação de Produtos(EKA)

oModel:SetRelation('EKEDETAIL', {{ 'EKE_FILIAL'	, 'xFilial("EKE")'  },;
											{ 'EKE_COD_I'	, 'EKD_COD_I' },;
											{ 'EKE_VERSAO' , 'EKD_VERSAO'}}, EKE->(IndexKey(1)) )
							

oModel:SetRelation('EKFDETAIL', {{ 'EKF_FILIAL'	, 'xFilial("EKF")'  },;
											{ 'EKF_COD_I'	, 'EKD_COD_I' },;
											{ 'EKF_VERSAO' , 'EKD_VERSAO'}}, EKF->(IndexKey(1)) )

oModel:SetRelation('EKIDETAIL', {{ 'EKI_FILIAL'	, 'xFilial("EKI")'  },;
											{ 'EKI_COD_I'	, 'EKD_COD_I' },;
											{ 'EKI_VERSAO' , 'EKD_VERSAO'}}, EKI->(IndexKey(1)) )
										
oModel:InstallEvent("CP401EV", , oMdlEvent)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ViewDef()
Local oStruEKD := FWFormStruct( 2, "EKD" )
Local oStruEKE := FWFormStruct( 2, "EKE", , /*lViewUsado*/ )
Local oStruEKF := FWFormStruct( 2, "EKF" )
Local oStruEKI := FWFormStruct( 2, "EKI" )
Local oView
Local oModel   := FWLoadModel( "EICCP401" )

//Cria o objeto de View
oView := FWFormView():New()                          // Adiciona no nosso View um controle do tipo formulário
oView:SetModel( oModel )                             // Define qual o Modelo de dados será utilizado na View
oView:AddField( 'VIEW_EKD', oStruEKD, 'EKDMASTER' )  // (antiga Enchoice)
oView:SetContinuousForm(.T.)
oView:CreateHorizontalBox( 'TELA' , 10 )            // Criar um "box" horizontal para receber algum elemento da view
oView:SetOwnerView( 'VIEW_EKD', 'TELA' )             // Relaciona o identificador (ID) da View com o "box" para exibição
oStruEKD:RemoveField("EKD_NALADI")
oStruEKD:RemoveField("EKD_GPCBRK")
oStruEKD:RemoveField("EKD_GPCCOD")
oStruEKD:RemoveField("EKD_UNSPSC")

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKE",oStruEKE , "EKEDETAIL")
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKE:RemoveField("EKE_FILORI")
EndIf

//Identificação do componente
oView:EnableTitleView( "VIEW_EKE", STR0021 ) //"Relação de Produtos"
oView:CreateHorizontalBox( 'INFERIOR_EKE'  , 45 )
oView:SetOwnerView( "VIEW_EKE", 'INFERIOR_EKE' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKF",oStruEKF , "EKFDETAIL")
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKF:RemoveField("EKF_FILORI")
EndIf

//Identificação do componente
oView:EnableTitleView( "VIEW_EKF", STR0022 ) //"Relação de Fabricantes"
oView:CreateHorizontalBox( 'INFERIOR_EKF'  , 23 )
oView:SetOwnerView( "VIEW_EKF", 'INFERIOR_EKF' )

//Identificação do componente
oView:AddGrid("VIEW_EKI",oStruEKI , "EKIDETAIL")
oView:EnableTitleView( "VIEW_EKI", STR0024 ) //"Relação de Atributos"
oView:CreateHorizontalBox( 'INFERIOR_EKI'  , 22 )
oView:SetOwnerView( "VIEW_EKI", 'INFERIOR_EKI' )
oStruEKI:RemoveField("EKI_VERSAO")
oStruEKI:RemoveField("EKI_COD_I")
oStruEKI:RemoveField("EKI_VALOR")

Return oView

/*
Programa   : CP401Canc
Objetivo   : Cancelar um Registro
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function CP401Canc(oMdl)
Local lRet := .T. 
Local oModel
Local lExec := .T.

   oModel := FWLoadModel("EICCP401")                                   //Carrega o modelo de dados para alteração
   oModel:SetOperation(4)
   oModel:Activate()

   If oModel:GetModel():GetValue("EKDMASTER","EKD_STATUS") != '1'
      EasyHelp(STR0013,STR0014) //"Apenas é possível cancelar registro de integração do catálogo de produto com status '2-Integrado' " #Atenção
      lRet := .F.
   EndIf

   If lRet .And. !lCP401Auto
      lExec := MsgYesNo(STR0011)                                          //"Confirma o cancelamento do registro desta integração de produto do catálogo ?"
   EndIf

   If lRet .And. lExec
      oModel:GetModel():GetModel("EKDMASTER"):SetValue("EKD_STATUS",'3')  //Alteracao Status do registro
      If oModel:VldData()
         lRet := oModel:CommitData()
      Else
         lRet := .F.
      EndIf
      If !lRet
         EasyHelp(GetErrMessage(oModel),STR0014)
      EndIf
   EndIf

   oModel:Deactivate()
   //Limpa o Objeto pra liberar memória
   FreeObj(oModel)

Return lRet
/*
Programa   : CP401POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function CP401POSVL(oMdl)
Local lRet := .T.

Do Case 
   Case oMdl:GetOperation() == 5  //Excluir
	   If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") <> "2"
		   EasyHelp(STR0012,STR0014) //"Apenas é possível excluir registro de integração do catálogo de produto com status '2-Não integrado' " #Atenção
		   lRet := .F.
	   EndIf
   Case oMdl:GetOperation() == 4  //Cancelar
      If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") != EKD->EKD_STATUS .And. oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") == '3' .And. EKD->EKD_STATUS != '1'
		   EasyHelp(STR0013,STR0014) //"Apenas é possível cancelar registro de integração do catálogo de produto com status '1-Integrado' " #Atenção
		   lRet := .F.
      EndIf
		
End Case

Return lRet

Static Function CP401COMMIT(oMdl)
Local lRet := .T.
Local cErro:= ""
Begin Transaction
	If oMdl:GetOperation() == 3  //Incluir	
		If TemNaoInteg(oMdl:GetModel():GetValue("EKDMASTER","EKD_COD_I"))
			cErro := DelNaoInteg(oMdl:GetModel():GetValue("EKDMASTER","EKD_COD_I"),oMdl:GetModel():GetValue("EKDMASTER","EKD_VERSAO"))
		EndIf
		If Empty(cErro)
			CancelaTudo(oMdl:GetModel():GetValue("EKDMASTER","EKD_COD_I"))
		EndIf
	EndIf
	If Empty(cErro)
		FWFormCommit(oMdl)
	Else
		DisarmTransaction()
	EndIf
End Transaction

If !Empty(cErro)
	EasyHelp(cErro,STR0014)
	lRet := .F.
EndIf

Return lRet
/*
Programa   : CP401Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP401Legen()
Local aCores := {}

   aCores := { {"BR_AMARELO"   ,STR0008   },;   //"Pendente Registro"
               {"ENABLE"       ,STR0009   },;   //"Registrado"
               {"BR_VERMELHO"  ,STR0010	},;   //"Obsoleto"
               {"BR_PRETO"     ,STR0025   },;   //"Falha de Integração"
               {"BR_AZUL"      ,STR0027   }}    //"Registrado (pendente: fabricante/país)"

   BrwLegenda(STR0007,STR0006,aCores)

Return .T.

/*
Programa   : CP401IniBw
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_INIPAD do cadastro do campo.
*/
Function CP401IniBw(cCpo)
Local xRet
Local oModel,oModelEKD

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")

   Do Case
      Case cCpo == "EKD_VERSAO"
         xret := Replicate(" ",TamSx3("EKD_VERSAO")[1] )
      Case cCpo == "EKD_STATUS"
         xRet := "2"
   End Case
Return xRet

/*
Programa   : CP401Trigg
Objetivo   : Executa os gatilhos dos campos da EKD
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_REGRA do gatilho do campo.
*/
Function CP401Trigg(cCpo)
Local xRet  := ""
Local oModel,oModelEKD,oModelEKE,oModelEKF,oModelEKI
Local lPosicEK9      := .F.

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")
   oModelEKE := oModel:GetModel("EKEDETAIL")
   oModelEKF := oModel:GetModel("EKFDETAIL")
   oModelEKI := oModel:GetModel("EKIDETAIL")

   EK9->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão Atual
   If EK9->(AvSeekLAst( xFilial("EK9") + oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I") )) 
      lPosicEK9 := .T.
   EndIf

   Do Case
      Case cCpo == "EKD_COD_I"
         EKD->(DbSetOrder(1))
         If EKD->(AvSeekLAst( xFilial("EKD") + oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I") ))
            //Se status for nao integrado, deve manter a mesam versao, pois ao salvar a versao nao integrada sera excluida
            If EKD->EKD_STATUS == '2'
               xRet := EKD->EKD_VERSAO
            elseif EKD->EKD_STATUS $ '3|4'
               xRet := SomaIt( EKD->EKD_VERSAO )
            EndIf
         Else
            xRet := StrZero(1,TamSX3("EKD_VERSAO")[1])
         EndIf
         LoadCpoMod( oModelEKD )
         LoadModEKE( oModelEKE )
         LoadModEKF( oModelEKF )
         LoadModEKI( oModelEKI )
   End Case

Return xRet

/*
Programa   : CP401SX7Cd
Objetivo   : Determina se o gatilho de um campo da EKD será executado.
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_COND do gatilho do campo.
*/
Function CP401SX7Cd(cCpo)
Local lRet
Local oModel,oModelEKD

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")
Do Case
   Case cCpo == "EKD_COD_I"
      lRet := !Empty(oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I"))
EndCase

Return lRet

/*
Programa   : CP401Val
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_VALID do cadastro do campo.
*/
Function CP401Val(cCpo)
Local lRet := .T.
Local oModel,oModelEKD,cCod_I

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")

Do Case
   Case cCpo == "EKD_COD_I"
      cCod_I := oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I")
      lRet := ExistCpo( "EK9", cCod_I , 1 )
		If lRet .And. TemNaoInteg(cCod_I) //Verifica se ja existe registro nao integrado para o codigo informado
			If IsMemVar("lCP401Auto") .And. !lCP401Auto 
				MsgInfo(STR0023,STR0014)//"Foi identificado um registro com o Status 'Não integrado' para este mesmo código. O registro será excluído automaticamente ao confirmar a inclusão deste novo registro."###"Atenção"
			EndIf
		EndIf
End Case

Return lRet

/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("EKD")
Local aContextos := {"NAO_INTEGRADO", "INTEGRADO", "CANCELADO", "FALHA_INTEGRACAO","INTEGRADO_PENDENTE_FABRICANTE_PAIS"}
Local cFiltro
Local i

      If aScan(aColunas, "EKD_FILIAL") == 0
         aAdd(aColunas, "EKD_FILIAL")
      EndIf

      For i := 1 To Len(aContextos)
         cFiltro := RetFilter(aContextos[i])
         oDSView := FWDSView():New()
         oDSView:SetName(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.))
         oDSView:SetPublic(.T.)
         oDSView:SetCollumns(aColunas)
         oDSView:SetOrder(1)
         oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .F.), cFiltro)
         oDSView:SetID(AllTrim(Str(i)))
         oDsView:SetLegend(.T.)
         aAdd(aVisions, oDSView)
      Next

Return aVisions

/*
Função     : RetFilter(cTipo)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
Local cRet		:= ""
Default lNome	:= .F.

      Do Case
         Case cTipo == "NAO_INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '2' "
         Case cTipo == "NAO_INTEGRADO" .And. lNome
            cRet := STR0008 //"Pendente Registro"

         Case cTipo == "INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '1' "
         Case cTipo == "INTEGRADO" .And. lNome
            cRet  := STR0009 //"Registrado"

         Case cTipo == "CANCELADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '3' "
         Case cTipo == "CANCELADO" .And. lNome
            cRet := STR0010 //"Obsoleto"

         Case cTipo == "FALHA_INTEGRACAO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '4' "
         Case cTipo == "FALHA_INTEGRACAO" .And. lNome
            cRet := STR0025 //"Falha de Integração"

         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. !lNome
            cRet := "EKD->EKD_STATUS = '5' "
         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. lNome
            cRet := STR0027 //"Registrado (pendente: fabricante/país)" 
            
      EndCase

Return cRet

Static Function LoadCpoMod( oMdl )
Local aArea			:= GetArea()
Local lRet

If ValType(oMdl) == "O" .And. EK9->(!Eof())   
   oMdl:SetValue("EKD_IDPORT",EK9->EK9_IDPORT)   
   oMdl:SetValue("EKD_CNPJ"  ,AvKey(EK9->EK9_CNPJ, "EKD_CNPJ"))
   oMdl:SetValue("EKD_MODALI",EK9->EK9_MODALI)
   oMdl:SetValue("EKD_NCM"   ,EK9->EK9_NCM)
   oMdl:SetValue("EKD_UNIEST",EK9->EK9_UNIEST)
   oMdl:SetValue("EKD_OBSINT",EK9->EK9_OBSINT)
   oMdl:SetValue("EKD_RETINT",EK9->EK9_RETINT)
   //oMdl:SetValue("EKD_USERIN",cUserNAme) //Sera gravado o usuario da integração
   lRet := .T.
Else
   lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
Função     : LoadModEKE(oModel)
Objetivo   : Carregar dados de relação de produtos do catalogo
Parâmetros : oModel - objeto do grid relaçao de prod
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Static Function LoadModEKE( oModelEKE )
Local aArea  	:= getArea()
Local nContLn	:= 1
Local lRet 		:= .F.

If Valtype(oModelEKE) == "O" .And. EK9->(!Eof())
	oModelEKE:SetNoDeleteLine(.F.)
	oModelEKE:SetNoInsertLine(.F.)
   If oModelEKE:Length() > 0
      CP400Clear(oModelEKE)
   EndIf
   DbSelectArea("EKA")
   EKA->(DbSetOrder(1)) //EKA_FILIAL+EKA_COD_I+EKA_VERSAO
   If MsSeek(xFilial("EKA")+EK9->EK9_COD_I)
      While EKA->(!EOF()) .And. xFilial("EKA")+EKA->EKA_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I
         If nContLn <> 1
           oModelEKE:AddLine()
         EndIf          
         oModelEKE:GoLine(nContLn)
         oModelEKE:SetValue("EKE_FILIAL"	,EKA->EKA_FILIAL)
         oModelEKE:SetValue("EKE_ITEM"		,EKA->EKA_ITEM)
		 	oModelEKE:SetValue("EKE_PRDREF"	,EKA->EKA_PRDREF)
         If lMultiFil 
            oModelEKE:SetValue("EKE_FILORI"	,EKA->EKA_FILORI)
            oModelEKE:SetValue("EKE_DESC_I"	, Posicione("SB1",1,EKA->EKA_FILORI+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC"))
         Else
            oModelEKE:SetValue("EKE_DESC_I"	,Posicione("SB1",1,XFILIAL("SB1")+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC"))
         EndIf
        
         lRet := .T.         
         nContLn++
         EKA->(DbSkip())
      EndDo   
   EndIf
   oModelEKE:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKE:SetNoDeleteLine(.T.)
oModelEKE:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Função     : LoadModEKF(oModel)
Objetivo   : Carregar dados de relação de fabricantes do catalogo
Parâmetros : oModel - objeto do grid relaçao de fabric.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Static Function LoadModEKF( oModelEKF )
Local aArea  	   := getArea()
Local nContLn	   := 1
Local lRet 		   := .F.
//Local lDeletedFB  := .F. //Retirado as ocorrências da variável lDeletedFB, não tem sentido tratar registros deletados
Local lStatInteg  := .F. 
Local QryFb       := ""
Local cCatalogo   := ""
Local cFilEKF     := ""
Local cChaveEKJ   := ""
Local cChaveEKJ2   := ""
Local cChaveSA2   := ""
Local cPais       := ""

If Valtype(oModelEKF) == "O" .And. EK9->(!Eof())
	oModelEKF:SetNoDeleteLine(.F.)
	oModelEKF:SetNoInsertLine(.F.)   
   If oModelEKF:Length() > 0
      CP400Clear(oModelEKF)
   EndIf 

   cCatalogo := EK9->EK9_COD_I  
   DbSelectArea("EKB")
   EKB->(DbSetOrder(1)) //EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
   If MsSeek(xFilial("EKB")+cCatalogo)      
      lStatInteg := CP401GetSt(cCatalogo)

      QryFb := " SELECT EKB_CODFAB, EKB_LOJA, D_E_L_E_T_ AS DELETED"  
      If lEkbPAis
         QryFb += ", EKB_PAIS "
      EndIf
      If lMultifil
         QryFb += ", EKB_FILORI "
      EndIf
      
      QryFb += " FROM " + RetSQLName("EKB")
      QryFb += " WHERE EKB_FILIAL = '" + xFilial("EKB") + "' "
      QryFb += "   AND EKB_COD_I  = '" + cCatalogo + "' "
      //Não tem sentido tratar registros deletados
      //If !lStatInteg   //para casos onde a última versão da Integração do catálogo está com status diferente de "Integrado/Registrado"
         QryFb += "   AND D_E_L_E_T_ = ' ' " 
      //EndIf
      QryFb:= ChangeQuery(QryFb)
      DBUseArea(.T., "TopConn", TCGenQry(,, QryFb), "WkQryFb", .T., .T.)

      WkQryFb->(DBGoTop())
   
      While WkQryFb->(!EOF()) 
         // lDeletedFB := .F.   //Retirado as ocorrências da variável lDeleteFB, não tem sentido tratar registros deletados
         If nContLn <> 1
            oModelEKF:AddLine()
         EndIf

         oModelEKF:GoLine(nContLn)            
         oModelEKF:SetValue("EKF_CODFAB",WkQryFb->EKB_CODFAB)
         oModelEKF:SetValue("EKF_LOJA",WkQryFb->EKB_LOJA)
         If lMultiFil 
            oModelEKF:SetValue("EKF_FILORI",WkQryFb->EKB_FILORI)
            cFilEKF := WkQryFb->EKB_FILORI
            oModelEKF:SetValue("EKF_NOME",POSICIONE("SA2",1,WkQryFb->EKB_FILORI+WkQryFb->EKB_CODFAB+WkQryFb->EKB_LOJA,"A2_NOME"))            
         Else
            cFilEKF := xFilial("EKF")
            oModelEKF:SetValue("EKF_NOME",POSICIONE("SA2",1,XFILIAL("SA2")+WkQryFb->EKB_CODFAB+WkQryFb->EKB_LOJA,"A2_NOME"))            
         EndIf 

         If lEkbPais
            oModelEKF:SetValue("EKF_PAIS", WkQryFb->EKB_PAIS)
            oModelEKF:LoadValue("EKF_PAISDS", POSICIONE("SYA",1,xFilial("SYA")+WkQryFb->EKB_PAIS,"YA_DESCR"))
            cPais := WkQryFb->EKB_PAIS
         EndIf   

         If SA2->(dbsetorder(1),msseek(cChaveSA2))
            cChaveEKJ := SA2->A2_FILIAL+EK9->EK9_CNPJ+SA2->A2_COD+SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            If EKJ->(msseek(cChaveEKJ)) .Or. EKJ->(msseek(cChaveEKJ2))
               oModelEKF:LoadValue("EKF_OPERFB", EKJ->EKJ_TIN)
            EndIf
         EndIf   

         /* //Retirado as ocorrências da variável lDeleteFB, não tem sentido tratar registros deletados
         If !Empty(WkQryFb->DELETED)
            lDeletedFB := .T.
         EndIf
         */
         
         If lEKFVincFB .And. lStatInteg                                                                                                         //Retirado as ocorrências da variável lDeleteFB, não tem sentido tratar registros deletados
            oModelEKF:LoadValue("EKF_VINCFB", CP401Vinc(cFilEKF,cCatalogo, CP401GetVs(cCatalogo), WkQryFb->EKB_CODFAB, WkQryFb->EKB_LOJA,cPais)) //o default é False,lDeletedFB  
         EndIf

         lRet := .T.
         nContLn++
         WkQryFb->(DbSkip())
      EndDo  
      WkQryFb->(dbcloseArea())       
   EndIf
   
   oModelEKF:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKF:SetNoDeleteLine(.T.)
oModelEKF:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Função     : CP401Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Parâmetros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :  
*/
Function CP401Gatil(cCampo)
Local aArea		   := GetArea()
Local oModel	   := FWModelActive()
Local oGridEKF    := oModel:GetModel("EKFDETAIL")
Local cRet        := ""

If cCampo == "EKF_PAISDS"   
   If !Empty(oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()))
      cRet := POSICIONE("SYA",1,xFilial("SYA")+oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()),"YA_DESCR")
   EndIf    
EndIf

RestArea(aArea)
Return cRet

/*
Função     : CP401GetSt()
Objetivo   : Retornar o ultimo status da versao do historico de integracao
Parâmetros : 
Retorno    : lRet - ultimo status é integrado .T. - .F. para nao integrado
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function CP401GetSt(cCatalogo)
Local lRet     := .F.
Local aArea := GetArea()


EKD->(DbSetOrder(1))
If EKD->(AvSeekLAst( xFilial("EKD") + cCatalogo ))
   If EKD->EKD_STATUS == '3'
      lRet := .T. //integrado
   EndIf 
EndIf

RestArea(aArea)
Return lRet

/*
Função     : CP401GetVs()
Objetivo   : Retornar a ultima versao do historico de integracao
Parâmetros : 
Retorno    : lRet - ultima versao 
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function CP401GetVs(cCatalogo)
Local cVersao := ""
Local aArea := GetArea()

EKD->(DbSetOrder(1))
If EKD->(AvSeekLAst( xFilial("EKD") + cCatalogo ))
   cVersao := EKD->EKD_VERSAO
EndIf

RestArea(aArea)
Return cVersao


/*
Função     : LoadModEKI(oModel)
Objetivo   : Carregar dados de relação de atributos do catalogo
Parâmetros : oModel - objeto do grid relaçao de atributos.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Static Function LoadModEKI( oModelEKI )
Local aArea    := getArea()
Local aAreaEKC := EKC->(getArea())
Local aAreaEKG := EKG->(getArea())
Local nContLn	:= 1
Local lRet     := .F.
Local cNome    := ""
Local cChaveEKG:= ""

   If Valtype(oModelEKI) == "O" .And. EK9->(!Eof())
      oModelEKI:SetNoDeleteLine(.F.)
      oModelEKI:SetNoInsertLine(.F.)
      If oModelEKI:Length() > 0
         CP400Clear(oModelEKI)
      EndIf
      DbSelectArea("EKC")
      EKC->(DbSetOrder(1)) //EKC_FILIAL+EKC_COD_I+EKC_CODATR
      If MsSeek(xFilial("EKC")+EK9->EK9_COD_I)
         While EKC->(!EOF()) .And. xFilial("EKC")+EKC->EKC_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I
            //Se utilizar campos da EKG só usar após a linha de baixo onde posiciona o registro nesta tabela
            cChaveEKG := xFilial("EKG")+EK9->EK9_NCM+EKC->EKC_CODATR
            EKG->(dbsetorder(1),msseek(cChaveEKG)) // POSICIONE("EKG",1,xFilial("EKC")+EK9->EK9_NCM+EKC->EKC_CODATR,"EKG_NIVIG")
            If nContLn <> 1
            oModelEKI:AddLine()
            EndIf
            cNome := (iif(EKG->EKG_OBRIGA == "1","* ","")) + AllTrim(EKG->EKG_NOME)
            oModelEKI:GoLine(nContLn)
            oModelEKI:SetValue("EKI_CODATR"  ,EKC->EKC_CODATR)
            oModelEKI:SetValue("EKI_STATUS"  ,CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG))
            oModelEKI:SetValue("EKI_NOME"    , cNome )
            oModelEKI:SetValue("EKI_VALOR"   ,CP401Valor(alltrim(EKG->EKG_FORMA),.F.))
            oModelEKI:SetValue("EKI_VLEXIB"  ,CP401Valor(alltrim(EKG->EKG_FORMA),.T.))
            lRet := .T.
            nContLn++
            EKC->(DbSkip())
         EndDo
      EndIf
      oModelEKI:GoLine(1)
      oModelEKI:SetNoDeleteLine(.T.)
      oModelEKI:SetNoInsertLine(.T.)
   Else
      lRet := .F.
   Endif

   RestArea(aArea)
   RestArea(aAreaEKC)
   RestArea(aAreaEKG)

Return lRet

/*
Função     : CP401Vinc()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Parâmetros : Cod do Catalogo, FAbri, Loja, Pais do Fabr.
Retorno    : Retorna a string com o status do vinculo
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function CP401Vinc(cFilEKF,cCatalog,cVersaoEKF,cCodFab,cLojaFab,cPaisFb, lDeletedFB)
Local cVinculo    := ""
Local aArea       := GetArea()

Default lDeletedFB := .F.

If !lDeletedFB //registro não está deletado na EKB - Relação de Fabricantes ou Países de Origem(Catálogo)
   If !Empty(cVersaoEKF) .and. EKF->(dbsetorder(1),Msseek(cFilEKF+cCatalog+cVersaoEKF+cCodFab+cLojaFab+cPaisFb))
      cVinculo := "3" //sem alteracao   
   Else
      cVinculo := "1" //vincular ao catálogo   
   EndIf
Else
   If !Empty(cVersaoEKF) .and. EKF->(dbsetorder(1),Msseek(xFilial("EKF")+cCatalog+cVersaoEKF+cCodFab+cLojaFab+cPaisFb))
      If lEKFVincFB .AND. EKF->EKF_VINCFB  $ '5'
         cVinculo := "3" //sem alteração
      Else
         cVinculo := "2" //desvincular do catálogo   
      EndIf
   EndIf
EndIf   

RestArea(aArea)
Return cVinculo

/*
Função     : CP401Valor()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Parâmetros : lTrunca, se true trunca o valor do tipo texo em 100 posições
Retorno    : Retorna a stringa com o valor
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP401Valor(cForma,lTrunca)
cRetorno:=""
DO CASE
   CASE cForma == "LISTA_ESTATICA"
        cRetorno := alltrim(EKC->EKC_VALOR) + "-" + POSICIONE("EKH",1,xFilial("EKH")+EK9->EK9_NCM+EKC->EKC_CODATR+EKC->EKC_VALOR,"EKH_DESCRE")
   CASE cForma == "BOOLEANO"
        cRetorno := if(EKC->EKC_VALOR == "", "", if(EKC->EKC_VALOR =="1", "1-Sim", "2-Nao"))
   CASE cForma == "TEXTO"
        cRetorno := if(lTrunca,substr(EKC->EKC_VALOR,1,100),EKC->EKC_VALOR)
   CASE cForma == "NUMERO_REAL"
        cRetorno := EKC->EKC_VALOR
EndCase
Return cRetorno


Static Function GetErrMessage(oModel)
Local cRet := ""
Local aErro

aErro   := oModel:GetErrorMessage(.T.)
// A estrutura do vetor com erro é:
//  [1] Id do formulário de origem
//  [2] Id do campo de origem
//  [3] Id do formulário de erro
//  [4] Id do campo de erro
//  [5] Id do erro
//  [6] mensagem do erro
//  [7] mensagem da solução
//  [8] Valor atribuido
//  [9] Valor anterior

If !Empty(aErro[4]) .AND. SX3->(dbSetOrder(2),dbSeek(aErro[4]))
   xInfo := if(ValType(aErro[8])=="U",aErro[9],aErro[8])
   cRet += "Erro ao preencher campo '"+PadR(AvSX3(aErro[4],AV_TITULO),Len(SX3->X3_TITULO))+"' com valor "+if(ValType(xInfo)=="C","'","")+AllTrim(AvConvert(ValType(xInfo),"C",,xInfo))+if(ValType(xInfo)=="C","'","")+": "+aErro[6]+" "
Else
   cRet += "Registro Inválido ("+AllTrim(aErro[3])+"): "+AllTrim(aErro[6])+IF(Len(aErro[7]) > 2," Solução: "+AllTrim(aErro[7]),"")
EndIf

Return cRet

/*
Função     : CP400Clear(oModel)
Objetivo   : Limpar dados do grid desejado
Parâmetros : oModel - objeto do grid 
Retorno    : lRet - Retorno se foi feito com sucesso a limpa dos dados
Autor      : Ramon Prado
Data       : Jan/2020
Revisão    :
*/
Static Function CP400Clear(oModel)
Local aArea   		  := GetArea()
Local lRet	    	  := .F.
Local nI := 0

For nI := 1 To oModel:Length()
   oModel:GoLine( nI )
   If !oModel:IsDeleted()
      oModel:DeleteLine()
   EndIf
Next

oModel:ClearData()

RestArea(aArea)
Return lRet

/*
Programa   : TemNaoInteg
Objetivo   : Verifica se para o codigo informado, existe registro nao integrado
Retorno    : .T. quando encontrar registro nao integrado; .F. não encontrar registro nao integrado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function TemNaoInteg(cCod_I)
Local lRet := .F.
Local cQuery

cQuery := "SELECT EKD_COD_I FROM " + RetSQLName("EKD")
cQuery += " WHERE EKD_FILIAL = '" + xFilial("EKD") + "' "
cQuery += "   AND EKD_COD_I  = '" + cCod_I + "' "
cQuery += "   AND EKD_STATUS = '2' " //
cQuery += "   AND D_E_L_E_T_ = ' ' "

If EasyQryCount(cQuery) != 0
	lRet := .T.
EndIf

Return lRet

/*
Programa   : DelNaoInteg
Objetivo   : Delete o registro nao integrado ao incluir um novo registro.
Retorno    : .T. caso a exclusão tenha sido realizada; .F. caso não tenha sido efetivada a exclusão
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 02/01/2020
*/
Static Function DelNaoInteg(cCod_I,cVersaoEKD)
Local cRet  	:= ""
Local aCapaEKD := {}
Local oErro		:= AvObject():New()
aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")	, Nil})
aAdd(aCapaEKD,{"EKD_COD_I"	, cCod_I				, Nil})
aAdd(aCapaEKD,{"EKD_VERSAO", cVersaoEKD		, Nil})

EasyMVCAuto("EICCP401",5,{{"EKDMASTER", aCapaEKD}},oErro)
If oErro:HasErrors()
	cRet := oErro:GetStrErrors()
EndIf

Return cRet

/*
Programa   : CancelaTudo
Objetivo   : Alterar o status de todos os registros do codigo informado para 3-Cancelado
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function CancelaTudo(cCod_I)
Local aAreaEKD := EKD->(getArea())

EKD->(dbSetOrder(1)) //EKD_FILIAL, EKD_COD_I, EKD_VERSAO
If EKD->(dbSeek(xFilial("EKD") + cCod_I))

	While EKD->(!EOF()) .And. EKD->EKD_FILIAL == xFilial("EKD") .And. EKD->EKD_COD_I == cCod_I
		If EKD->EKD_STATUS != '3'
			RecLock("EKD",.F.)
			EKD->EKD_STATUS := '3' //Cancelado
			EKD->(MsUnlock())
		EndIf
		EKD->(dbSkip())
	End

EndIf

RestArea(aAreaEKD)
Return

/*
CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
MFR - Maurício Frison
 */
Class CP401EV FROM FWModelEvent
     
    Method New()
    Method Activate()

End Class

Method New() Class CP401EV
Return

Method Activate(oModel,lCopy) Class CP401EV
  CP401AtuAtrib(oModel)
Return

Function CP401AtuATrib(oModel)
Local oModelEKI	:= oModel:GetModel("EKIDETAIL")
Local nI
Local nOperation := oModel:GetOperation()
If nOperation == 5 //Exclusão
    oModel:nOperation := 3
EndIf
If oModelEKI:Length() > 0
		oModelEKI:GoLine(1)
		For nI := 1 to oModelEKi:Length()
			oModelEKI:GoLine( nI )
         oModelEKI:LoadValue("EKI_VLEXIB",substr(oModelEKI:getValue("EKI_VALOR"),1,100))
      Next
      oModelEKI:GoLine(1)
EndIf
oModel:nOperation := nOperation
return .t.
