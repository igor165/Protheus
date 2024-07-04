#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#include 'eiccp400.ch'
#Include "TOPCONN.CH"

/*
Programa   : EICCP400
Objetivo   : Rotina - Catalogo de Produtos
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Dez /2019
Obs.       :
*/
function EICCP400(aCapaAuto,aItensAuto,nOpcAuto)
   Local aArea       := GetArea()
   Local aCores      := {}
   Local nX          := 1
   Local cModoAcEK9  := FWModeAccess("EK9",3)
   Local cModoAcEKA  := FWModeAccess("EKA",3)
   Local cModoAcEKB  := FWModeAccess("EKB",3)
   Local cModoAcEKD  := FWModeAccess("EKD",3)
   Local cModoAcEKE  := FWModeAccess("EKE",3)
   Local cModoAcEKF  := FWModeAccess("EKF",3)
   Local cModoAcSB1  := FWModeAccess("SB1",3)
   Local cModoAcSA2  := FWModeAccess("SA2",3)
   Local oBrowse

   Private lCP400Auto   := ValType(aCapaAuto) <> "U" .Or. ValType(aItensAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
   Private aRotina      := {}
   Private aAtrib       := {}
   Private cValor       := ""
   Private cNCm         := "          "
   Private cModalEK9    := ""
   Private cPrdRefEK9   := ""
   Private cNcmAux      := ""
   Private lRetAux      :=.T.
   Private lMultiFil    := VerSenha(115) .And. cModoAcEK9 == "C" .And. cModoAcSB1 == "E" .And. cModoAcSA2 == "E"

      If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
         EasyHelp(STR0025,STR0002) // "Modo de compatilhamento esta diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "#Aten��o
      Else

         aCores := {	{"EK9_STATUS == '1' ","ENABLE"      ,STR0004	},; //"Registrado"
                     {"EK9_STATUS == '2' ","BR_CINZA"	   ,STR0005	},; //"Pendente Registro"
                     {"EK9_STATUS == '3' ","BR_AMARELO"	,STR0006	},; //"Pendente Retifica��o"
                     {"EK9_STATUS == '4' ","DISABLE"     ,STR0007	}}	//"Bloqueado"
         
         INCLUI := nOpcAuto == INCLUIR //Vari�vel INCLUI utilizada no dicion�rio de dados da ek9 para nao permitir alterar o ncm
         
         If !lCP400Auto
            oBrowse := FWMBrowse():New() //Instanciando a Classe
            oBrowse:SetAlias("EK9") //Informando o Alias 
            oBrowse:SetMenuDef("EICCP400") //Nome do fonte do MenuDef
            oBrowse:SetDescription(STR0001) // "Catalogo de Produtos" //Descri��o a ser apresentada no Browse   
         
            //Adiciona a legenda
            For nX := 1 To Len( aCores )   	    
               oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
            Next nX
            
            //Habilita a exibi��o de vis�es e gr�ficos
            oBrowse:SetAttach( .T. )
            //Configura as vis�es padr�o
            oBrowse:SetViewsDefault(GetVisions())
            
            //For�a a exibi��o do bot�o fechar o browse para fechar a tela
            oBrowse:ForceQuitButton()
            
            //Ativa o Browse
            oBrowse:Activate()
         Else
            //Defini��es de WHEN dos campos
            ALTERA := nOpcAuto == ALTERAR
            EXCLUI := nOpcAuto == EXCLUIR
         
            FWMVCRotAuto(ModelDef(), "EK9", nOpcAuto, {{"EK9MASTER",aCapaAuto}, {"EKADETAIL",aItensAuto}/*{"EYYDETAIL",aNFRem}*/ })
         EndIf
      EndIf

      RestArea(aArea)

Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function MenuDef()
   Local aRotina := {}

   aAdd( aRotina, { STR0008	, "AxPesqui"         , 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0009	, 'VIEWDEF.EICCP400'	, 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0010   , 'VIEWDEF.EICCP400'	, 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0011   , 'VIEWDEF.EICCP400'	, 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0012   , 'VIEWDEF.EICCP400'	, 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0013   , 'CP400Legen'	      , 0, 6, 0, NIL } )	//'Legenda'
   aAdd( aRotina, { STR0050   , 'CP400CadOE()'     , 0, 6, 0, NIL } )	//'"Cadastra Operador Estrangeiro" '
   aAdd( aRotina, { STR0045   , 'CP400Integrar()'  , 0, 6, 0, NIL } )	//'Integrar'
 
Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ModelDef()
   Local oStruEK9       := FWFormStruct( 1, "EK9", , /*lViewUsado*/ )
   Local oStruEKA       := FWFormStruct( 1, "EKA", , /*lViewUsado*/ )
   Local oStruEKB       := FWFormStruct( 1, "EKB", , /*lViewUsado*/ )
   Local oStruEKC       := FWFormStruct( 1, "EKC", , /*lViewUsado*/ )
   Local bCommit        := {|oModel| CP400COMMIT(oModel)}
   Local bPosValidacao  := {|oModel| CP400POSVL(oModel)}
   // Local bPreValidacao  := {|oModel| CP400PREVL(oModel)}
   Local bCancel        := {|oModel| CP400CANC(oModel)}
   Local oMdlEvent      := CP400EV():New()
   Local bPreVldEKC     := {|oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue| EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)}
   Local bPreVldEKA     := {|oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue| EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)}   
   Local bPosVldEKA     := {|oGridEKA| EKALineValid(oGridEKA)}
   Local bLnPosEKB      := {|oGridEKB| EKBLnVlPos(oGridEKB)}
   Local oModel         // Modelo de dados que ser� constru�do	
   Local lMultifil      := VerSenha(115) .And. FWModeAccess("EK9",3) == "C" .And. FWModeAccess("SB1",3) == "E" .And. FWModeAccess("SA2",3) == "E"   

      // Cria��o do Modelo
      oModel := MPFormModel():New( "EICCP400", /*bPreValidacao*/, bPosValidacao, bCommit, bCancel )
      //step 2
      //oModel:setOperation(4)
      If !lMultiFil
         oStruEK9:RemoveField("EK9_FILORI")
      EndIf

      oStruEK9:RemoveField("EKD_NALADI")
      oStruEK9:RemoveField("EKD_GPCBRK")
      oStruEK9:RemoveField("EKD_GPCCOD")
      oStruEK9:RemoveField("EKD_UNSPSC")
      oStruEK9:SetProperty('EK9_MSBLQL'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_MSBLQL")'    )) //Monta When diferente do dicion�rio

      // Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
      oModel:AddFields("EK9MASTER", /*cOwner*/ ,oStruEK9 )
      oModel:SetPrimaryKey( { "EK9_FILIAL", "EK9_COD_I"} )	

      // Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Rela��o de Produtos
      oModel:AddGrid("EKADETAIL","EK9MASTER", oStruEKA, bPreVldEKA , bPosVldEKA, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKADETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Produto - OSSME-5771 - Crit�rio 7
      oStruEKA:RemoveField("EKA_COD_I")

      // Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Fabricantes
      oModel:AddGrid("EKBDETAIL","EK9MASTER", oStruEKB, /*bLinePre*/ ,bLnPosEKB, /*bPreVal*/ , /* bPosValEKB */, /*BLoad*/ )   
      oModel:GetModel("EKBDETAIL"):SetOptional( .T. ) //apesar de ser opcional, ser� validado no PosValid e obrigado a informar ao menos um fabricante ou pa�s
      oStruEKB:RemoveField("EKB_COD_I")

      // Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Atributos
      oModel:AddGrid("EKCDETAIL","EK9MASTER", oStruEKC, bPreVldEKC ,/*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKCDETAIL"):SetOptional( .T. ) 
      oModel:GetModel("EKCDETAIL"):SetNoInsertLine(.T.) 
      //oModel:GetModel("EKCDETAIL"):SetDelAllLine(.T.)
      oModel:GetModel("EKCDETAIL"):SetNoDeleteLine(.F.)
      //oModel:GetModel("EKCDETAIL"):SetNoUpdateLine(.T.)
      

      oStruEKC:RemoveField("EKC_COD_I")
      //oStruEKC:RemoveField("EKC_VERSAO")

      If !lMultiFil
         oStruEKA:RemoveField("EKA_FILORI")
      EndIf

      If !lMultiFil
         oStruEKB:RemoveField("EKB_FILORI")
      EndIf

      //Modelo de rela��o entre Capa - Produto Referencia(EK9) e detalhe Rela��o de Produtos(EKA)
      oModel:SetRelation('EKADETAIL', {{ 'EKA_FILIAL' , 'xFilial("EKA")' },;
                                       { 'EKA_COD_I'  , 'EK9_COD_I'     }},;
                                       EKA->(IndexKey(1)) )
                                    
      oModel:SetRelation('EKBDETAIL', {{ 'EKB_FILIAL' , 'xFilial("EKB")' },;
                                       { 'EKB_COD_I'  , 'EK9_COD_I'     }},;
                                       EKB->(IndexKey(1)) )

      oModel:SetRelation('EKCDETAIL', {{ 'EKC_FILIAL'	, 'xFilial("EKC")' },;
                                       { 'EKC_COD_I'  , 'EK9_COD_I'     }},;
                                       EKC->(IndexKey(1)) )
                                    
      If lMultiFil
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF","EKA_FILORI"} )
      Else
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF"} )
      EndIf	
      
      If oStruEKB:hasField("EKB_PAIS")
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_PAIS","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA", "EKB_PAIS"} )
         EndIf	
      Else
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA"} )
         EndIf	
      EndIf   

      //Adiciona a descri��o do Componente do Modelo de Dados
      oModel:GetModel("EK9MASTER"):SetDescription(STR0001) //"Catalogo de Produtos"
      oModel:SetDescription(STR0001) // "Catalogo de Produtos"
      oModel:GetModel("EKADETAIL"):SetDescription(STR0014) //'Rela��o do Cat�logo de Produtos'
      oModel:GetModel("EKBDETAIL"):SetDescription(STR0024) //"Rela��o de Pa�ses de Origem e Fabricantes "
      oModel:GetModel("EKCDETAIL"):SetDescription(STR0040) //"Rela��o de Atributos"

      oModel:InstallEvent("CP400EV", , oMdlEvent)
      //step 2
      //oModel:setOperation(4)
      
      oStruEK9:SetProperty("EK9_CNPJ",MODEL_FIELD_TAMANHO, AVSX3("EKJ_CNPJ_R", 3))
      //oStruEKB:SetProperty('EKB_CODFAB',MODEL_FIELD_OBRIGAT, .F. )
   
Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ViewDef()
   Local oStruEK9 := FWFormStruct( 2, "EK9" )
   Local oStruEKA := FWFormStruct( 2, "EKA" )
   Local oStruEKB := FWFormStruct( 2, "EKB" )
   Local oStruEKC := FWFormStruct( 2, "EKC" )
   Local oModel   := FWLoadModel( "EICCP400" )
   Local oView

      //Cria o objeto de View
      oView := FWFormView():New()

      // Adiciona no nosso View um controle do tipo formul�rio 
      //Define qual o Modelo de dados ser� utilizado na View
      oView:SetModel( oModel )

      oView:SetContinuousForm(.T.)
      oView:CreateHorizontalBox( 'TELA', 10)
      // (antiga Enchoice)
      oView:AddField( 'VIEW_EK9', oStruEK9, 'EK9MASTER' )
      // Relaciona o identificador (ID) da View com o "box" para exibi��o
      oView:SetOwnerView( 'VIEW_EK9', 'TELA' )
      //Identifica��o do componente
      oView:EnableTitleView( "VIEW_EK9", STR0001 ) //"Catalogo de Produtos(Capa)"
      oStruEK9:RemoveField("EK9_NALADI")
      oStruEK9:RemoveField("EK9_GPCBRK")
      oStruEK9:RemoveField("EK9_GPCCOD")
      oStruEK9:RemoveField("EK9_UNSPSC")
      
      //oView:CreateHorizontalBox( 'SUPERIOR'  , 30 )
      oView:CreateHorizontalBox( 'INFERIOR_EKA'  , 30 )

      If !lMultiFil
         oStruEK9:RemoveField("EK9_FILORI")
      EndIf

      //Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
      oView:AddGrid("VIEW_EKA",oStruEKA , "EKADETAIL")
      oStruEKA:RemoveField("EKA_COD_I")
      //Identifica��o do componente
      oView:EnableTitleView( "VIEW_EKA", STR0015 ) //"Rela��o de Produtos"

      oView:SetOwnerView( "VIEW_EKA", 'INFERIOR_EKA' )

      //Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
      oView:AddGrid("VIEW_EKB",oStruEKB , "EKBDETAIL")
      oStruEKB:RemoveField("EKB_COD_I")

      //Identifica��o do componente
      oView:EnableTitleView( "VIEW_EKB", STR0024) //"Rela��o de Pa�ses de Origem e Fabricantes "

      oView:CreateHorizontalBox( 'INFERIOR_EKB'  , 30 )

      oView:SetOwnerView( "VIEW_EKB", 'INFERIOR_EKB' )

      //GRID DE ATRIBUTOS
      //Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
      oView:AddGrid("VIEW_EKC",oStruEKC , "EKCDETAIL")
      oStruEKC:RemoveField("EKC_COD_I")
      oStruEKC:RemoveField("EKC_VERSAO")
      oStruEKC:RemoveField("EKC_VALOR")
      //Step 1
      oView:SetViewProperty("EKCDETAIL", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})  
      //Step 1
      //Identifica��o do componente
      oView:EnableTitleView( "VIEW_EKC", "Rela��o de Atributos") //"Rela��o de Atributos"

      oView:CreateHorizontalBox( 'INFERIOR_EKC'  , 30 )

      oView:SetOwnerView( "VIEW_EKC", 'INFERIOR_EKC' )

      If !lMultiFil
         oStruEKA:RemoveField("EKA_FILORI")
      EndIf

      If !lMultiFil
         oStruEKB:RemoveField("EKB_FILORI")
      EndIf

      oView:AddIncrementField( 'VIEW_EKA', 'EKA_ITEM' )

      oStruEK9:SetProperty("EK9_CNPJ",MVC_VIEW_PICT, AVSX3("EKJ_CNPJ_R", 6) )
      
Return oView

/*
Programa   : CP400CANC
Objetivo   : A��o ao clicar no botao cancelar
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400CANC(oMdl)

   RollbackSx8()

Return .T.

/*
Programa   : CP400PREVL
Objetivo   : Funcao de Pre Validacao
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400PREVL(oMdl)

   Local lRet			:= .T.
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local lPosicEKD   := .F.

      EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Vers�o
      If EKD->(AvSeekLAst( xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I") ))
         lPosicEKD := .T.
      EndIf

      If lPosicEKD .And. EKD->EKD_STATUS == '5' /*Registrado (pendente: fabricante/ pa�s)*/
         If MsgYesNo(STR0093) //"Existem pend�ncias de integra��o do Cat�logo de Produtos referente ao v�nculo de Operadores Estrangeiros. Deseja processar a integra��o pendente?" 
            lRet := CP400Integrar()
            If !lRet
               oMdl:SetOperation(MODEL_OPERATION_VIEW)
            EndIf
         Else
            lRet := .F.
            oMdl:SetOperation(MODEL_OPERATION_VIEW)
         EndIf
      EndiF

return lRet
/*
Programa   : CP400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400POSVL(oMdl)
   Local aArea			:= GetArea()
   Local lRet			:= .T.
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local oModelEKB	:= oMdl:GetModel("EKBDETAIL")
   Local oModelEKC	:= oMdl:GetModel("EKCDETAIL")
   Local nI			   := 1
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local lPosicEKD   := .F.
   Local lEasyhelp   := .F. 
   Local lEmpPais    := .T. 
                            

      EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Vers�o
      If EKD->(AvSeekLAst( xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I") ))
         lPosicEKD := .T.
      EndIf
   
      Begin Sequence
         If oMdl:GetOperation() == 5 //Exclus�o
            if Alltrim(oModelEK9:GetValue("EK9_STATUS")) <> "2"
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0003,STR0002) //"Apenas � poss�vel excluir Catalogo de produto com Status 'Registro Pendente' "##"Aten��o"
               break               
            EndIf
            
            If lPosicEKD .And. EKD->EKD_STATUS == '1' .Or. EKD->EKD_STATUS == '3' //Integrado ou Cancelado
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0048,STR0002) //"N�o � poss�vel excluir Catalogo de Produtos que possua integra��o com status Integrado ou Cancelado" //"Apenas � poss�vel excluir Catalogo de produto com Status 'Registro Pendente' "##"Aten��o"
               break               
            EndiF   

            If lRet .And. lPosicEKD
               If !TemIntegEKD(oModelEK9:GetVAlue("EK9_COD_I")) .And. EKD->EKD_STATUS == '2' //nao achou registros Integrados ou Cancelados e a Ultima versao � "Nao Integrado"            
                  cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro N�o Integrado     
               Else
                  lRet := .F.	
                  lEasyhelp := .T.
                  EasyHelp(STR0044,STR0002) // "N�o � poss�vel excluir Catalogo de Produtos que possua integra��o com status Integrado ou Cancelado""##"Aten��o"
                  break                  
               EndIf
            EndIf

         ElseIf	oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclus�o ou Altera��o	

            If oModelEKC:Length() > 0
               For nI := 1 to oModelEKC:Length()
                  oModelEKC:GoLine( nI )
                  if LEFT(oModelEKC:GetValue("EKC_NOME"),1) == "*" ;
                     .AND. Empty(oModelEKC:GetValue("EKC_VALOR")) ;
                     .AND. Alltrim(oModelEKC:GetValue("EKC_STATUS")) == "VIGENTE"
                        lRet := .F.	
                        lEasyhelp := .T.
                        EasyHelp(StrTran(STR0033, "###", oModelEKC:GetValue("EKC_CODATR")), ,STR0106) //"Atributo: ### � de preenchimento obrigat�rio e est� vazi." ### "Informe um valor para este campo e salve novamente."
                        break                        
                  EndIf
               Next            
            EndIf

            //grid ela��o de Pa�ses de Origem e Fabricantes Em branco - a linha 1 fica vazia - Lenght igual a 1 - quando h� dele��o de linhas volta a ficar 0 o Lenght
            If oModelEKB:hasField("EKB_PAIS")
               lEmpPais := Empty(oModelEKB:GetValue("EKB_PAIS"))
            EndIf
            If oModelEKB:Length(.T.) == 0 .Or. ;
                     oModelEKB:Length(.T.) == 1 .And. ;
                     Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_LOJA")) .And. ;
                     lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS"))
               EasyHelp(STR0083,STR0002,STR0084)  //Problema: "N�o foram informados fabricantes ou pa�ses de origem" Solu��o: "Informe ao menos um pa�s de origem ou fabricante para prosseguir"
            
               lRet := .F.	
               lEasyhelp := .T.
               break
            EndIf

            cIdManu  := oModelEK9:GetValue("EK9_IDMANU") 
            cVsManu  := oModelEK9:GetValue("EK9_VSMANU") 
            If !Empty(cIdManu) .And. Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0037,STR0002) // "Ao preencher o campo ID Manual tamb�m ser� necess�rio preencher o campo Vers�o Manual"##"Aten��o"
               break               
            EndIf

            If Empty(cIdManu) .And. !Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0041,STR0002) // "Ao preencher o campo ID Manual tamb�m ser� necess�rio preencher o campo Vers�o Manual"##"Aten��o"
               break               
            EndIf
            
            If(!empty(cVsManu) .and. lPosicEKD .And. (EKD->EKD_STATUS == '1' .Or. EKD->EKD_STATUS == '3'))
               If cVsManu < EKD->EKD_VERSAO
                  lRet := .F.   
                  lEasyhelp := .T.
                  EasyHelp(StrTran(STR0038, "###", EKD->EKD_VERSAO),STR0002) //"A vers�o informada manualmente � menor que a vers�o ### Integrada ou Cancelada"###"Aten��o"
                  break
               EndIf
            EndIf              
         EndIf
      End Sequence   
      //coloquei no commit n�o teve efeito, aqui j� � o evento posvalid
      If lREt .And. (oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4) //MFR 11/02/2022 OSSME-6595 
         For nI := 1 to oModelEKC:Length()
            oModelEKC:GoLine( nI )
            If Empty(oModelEKC:GetValue("EKC_VALOR"))
               oModelEKC:DeleteLine()
            EndIf
         Next
      EndIf   

      If !Empty(cErro)
         lRet := .F.
         lEasyhelp := .T.
         EasyHelp(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Aten��o
      EndIf

      RestArea(aArea)

      If oModelEKB:Length() > 0
         If lCP400Auto .and. !lRet .and. lEasyhelp
            lRet := .T.
         Endif
      EndIf

Return lRet
/*
Programa   : CP400COMMIT
Objetivo   : Funcao de Commit - utilizado para campos cujo formulario do mvc nao grava  
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Mar/2020
Obs.       :
*/
Static Function CP400COMMIT(oMdl)
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local oGridEKB    := oMdl:GetModel("EKBDETAIL")
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local cStatusEK9  := "" 
   Local lRet        := .T.
   Local lPosicEKD   := .F.
   Local lRetDif     := .F.
   Local aOEs        := {}
   Local lPendRetif  := .F.

      EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Vers�o
      If EKD->(AvSeekLAst( xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I") ))
         lPosicEKD := .T.
      EndIf

      If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao
         // Caso tenha operador estrangeiro relacionado ao produto n�o cadastrado cadastra via rotina autom�tica
         if CP400OEValid(oGridEKB,oModelEK9,@aOEs)
            CP400ExecEKJ(aOEs,oModelEK9)
            oMdl:activate()
         endif
      endif

      Begin Transaction
         
         If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao

            cIdManu  := oModelEK9:GetValue("EK9_IDMANU")
            cVsManu  := oModelEK9:GetValue("EK9_VSMANU")
            If !Empty(cIdManu) .And. !Empty(cVsManu) 
               oModelEK9:SetValue("EK9_ULTALT",cUserName)
               oModelEK9:SetValue("EK9_IDPORT", oModelEK9:GetValue("EK9_IDMANU") )
               oModelEK9:SetValue("EK9_VATUAL", oModelEK9:GetValue("EK9_VSMANU") )
            EndIf

            If (Empty(cVsManu) .And. oMdl:GetOperation() <> 3) .Or. ;
            (!Empty(cVsManu) .And. !Empty(EK9->EK9_VATUAL) .And. EK9->EK9_VATUAL >= cVsManu)
               lRetDif := VerificDif(oMdl)
               If lRetDif .And. !Empty(cVsManu) .And. cVsManu == EK9->EK9_VATUAL
                  //se foi encontrada diferen�a e se n�o for execauto exibe a pergunta. Sen�o segue como Sim(Existe Diferen�a)             
                  If lRetDif .And. IsMemVar("lCP400Auto") .And. !lCP400Auto .And. !MsgNoYes(STR0043,STR0002) //"O catalogo alterado foi registrado manualmente no portal �nico, 
                                                   //deseja gerar uma nova vers�o para integra��o autom�tica pelo sistema com os dados informados?" ## "Aten��o"
                     lRetDif := .F. 
                  EndIf
               EndIf         
            EndIf

            If oMdl:GetOperation() == 4 .and. lRetDif
               If lPosicEKD .And. ((!Empty(cVsManu) .And. cVsManu > EKD->EKD_VERSAO) .or. (Empty(cVsManu)) ) .And. EKD->EKD_STATUS == '2' //Pendente Registro
                  cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro N�o Integrado
               ElseIf lPosicEKD .And. ((!Empty(cVsManu) .And. cVsManu > EKD->EKD_VERSAO) .or. (Empty(cVsManu)) ) .And. EKD->EKD_STATUS $ '1' //Registrado
                  cErro := CancInteg(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Cancelamento de registro Integrado
                  lPendRetif := .T.
               EndIf
            EndIf

            if lRetDif .or. oMdl:GetOperation() == 3
               if oMdl:GetOperation() == 3
                  cStatusEK9 := "2"
               elseif lPendRetif .or. EK9->EK9_STATUS == "3"
                  cStatusEK9 := "3"
               elseif oModelEK9:GetValue("EK9_MSBLQL") == "1" 
                  cStatusEK9 := "4"
               else
                  cStatusEK9 := "2"
               endif
            EndIf

            If Empty(cErro)
               FWFormCommit(oMdl)
               //havendo diferen�as, versao manual igual a versao atual - resposta Sim para a pergunta de gerar Inclusao de Integracao Cat Prod.
               If (lRetDif .and. oModelEK9:GetValue("EK9_MSBLQL") <> "1") .Or. ( oMdl:GetOperation() == 3 .And. Empty(cVsManu) .And. Empty(oModelEK9:GetValue("EK9_VATUAL")) )
                  cErro := IncluInteg(oModelEK9)
                  if empty(cErro) .and. reclock("EK9",.F.)
                     EK9->EK9_VATUAL := EKD->EKD_VERSAO
                     EK9->EK9_STATUS := cStatusEK9
                     EK9->(msunlock())
                  endif
               EndIf

            Else
               DisarmTransaction()
            EndIf
         EndIf 

         If oMdl:GetOperation() == 5
            FWFormCommit(oMdl)
            If lPosicEKD
               cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro N�o Integrado     
            EndIf
         EndIf

      End Transaction

      //primeiro commita o catalogo com a altera��o do campo para depois incluir a integra��o e se houver erro a transa��o de inclusao
      //sera desarmada pela rotina EICCP401
      If !Empty(cErro)
         EECVIEW(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Aten��o 
         lRet := .F.
      EndIf

Return lRet

/*
Programa   : IncluInteg
Objetivo   : Funcao utilizada para Incluir integra��o do cat�logo de produtos 
Retorno    : Caractere - Erro da Execu��o Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function IncluInteg( oModelEK9)
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

      aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")                    , Nil})
      aAdd(aCapaEKD,{"EKD_COD_I"	, oModelEK9:GetValue("EK9_COD_I")   , Nil})

      MSExecAuto({|a,b| EICCP401(a,b)}, aCapaEKD, 3)

      If lMsErroAuto
         aErros := GetAutoGRLog()
         For nJ:= 1 To Len(aErros)
            cLogErro += aErros[nJ]+ENTER
         Next nJ
      EndIf

Return cLogErro

/*
Programa   : VerificDif(oMdl)
Objetivo   : Funcao utilizada para Incluir integra��o do cat�logo de produtos 
Retorno    : Caractere - Erro da Execu��o Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function VerificDif(oMdl)
   Local oModelEK9   := oMdl:GetModel("EK9MASTER")
   Local oModelEKA   := oMdl:GetModel("EKADETAIL")
   Local oModelEKB   := oMdl:GetModel("EKBDETAIL")
   Local oModelEKC   := oMdl:GetModel("EKCDETAIL")
   Local nI          := 0
   Local lAchouDif   := .F.
   Local cChaveEKA   := ""
   Local cChaveEKB   := ""
   Local cChaveEKC   := ""

      begin sequence      

         If EK9->EK9_IDPORT <> oModelEK9:GetValue("EK9_IDPORT") .Or. EK9->EK9_VATUAL <> oModelEK9:GetValue("EK9_VATUAL") .Or. ;
            EK9->EK9_IMPORT <> oModelEK9:GetValue("EK9_IMPORT") .Or. AvKey(EK9->EK9_CNPJ, "EKJ_CNPJ_R") <> AvKey(oModelEK9:GetValue("EK9_CNPJ"), "EKJ_CNPJ_R")   .Or. ;
            EK9->EK9_MODALI <> oModelEK9:GetValue("EK9_MODALI") .Or. EK9->EK9_NCM    <> oModelEK9:GetValue("EK9_NCM")    .Or. ;
            EK9->EK9_UNIEST <> oModelEK9:GetValue("EK9_UNIEST") .Or. EK9->EK9_STATUS <> oModelEK9:GetValue("EK9_STATUS") .Or. ;
            EK9->EK9_DSCCOM <> oModelEK9:GetValue("EK9_DSCCOM") .Or. EK9->EK9_RETINT <> oModelEK9:GetValue("EK9_RETINT") .Or. ;
            EK9->EK9_MSBLQL <> oModelEK9:GetValue("EK9_MSBLQL") .or. ;
            (lMultiFil .AND. EK9->EK9_FILORI <> oModelEK9:GetValue("EK9_FILORI")) 
               lAchouDif := .T.
               break
         EndIf

         For nI := 1 To oModelEKA:Length()
            oModelEKA:GoLine( nI )
            If oModelEKA:isInserted()
               lAchouDif := .T.
               break   
            EndIf
            if ! oModelEKA:isdeleted()
               cChaveEKA := xFilial("EKA") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKA_COD_I",3)) + oModelEKA:GetValue("EKA_PRDREF")
               If ! EKA->(DbSetOrder(1),MsSeek(cChaveEKA))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            EndIf
         Next nI
         
         For nI := 1 To oModelEKB:Length()
            oModelEKB:GoLine( nI )
            If oModelEKB:isInserted()
               lAchouDif := .T.
               break   
            EndIf
            if ! oModelEKB:isdeleted()
               cChaveEKB := xFilial("EKB") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKB_COD_I",3)) + oModelEKB:GetValue("EKB_CODFAB") + oModelEKB:GetValue("EKB_LOJA")
               If ! EKB->(dbsetorder(1),MsSeek(cChaveEKB))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            endif
         Next nI

         For nI := 1 To oModelEKC:Length()
            oModelEKC:GoLine( nI )
            If oModelEKC:isInserted()
               lAchouDif := .T.
               break   
            EndIf
            if ! oModelEKB:isdeleted()
               cChaveEKC := xFilial("EKC") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKC_COD_I",3)) + oModelEKC:GetValue("EKC_CODATR")
               If EKC->(dbsetorder(1),MsSeek( cChaveEKC ))
                  If EKC->EKC_VERSAO <> oModelEKC:GetValue("EKC_VERSAO") .Or. ;
                     EKC->EKC_VALOR  <> oModelEKC:GetValue("EKC_VALOR")
                     lAchouDif := .T.
                     break
                  EndIf
               elseIf !Empty(oModelEKC:GetValue("EKC_VALOR"))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            endif
         Next nI

      end sequence

Return lAchouDif
/*/{Protheus.doc} CP400Integrar
   Fun��o para realizar a integra��o do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aCatalogos - array com o recno do cat�logo de produtos a ser integrado, se vazio registra o posicionado no browse
   @return Nil
   /*/
Function CP400Integrar(aCatalogos)
   Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
   Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produ��o - portalunico.siscomex.gov.br 
   Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   Local cVers�oEKD  := ""
   Local cErros      := ""
   Local lRet        := .T.
   Local aRetIntCP   := {lRet,.T.}
   Local oProcess
   Local cLib

   Private cURLIACP    := "/catp/api/ext/produto"
   Private cURLAuth    := "/portal/api/autenticar"
   Private cURLIFbrPO  := "/catp/api/ext/fabricante"
   Private cCPPathAuth := ""
   Private cPathIACP   := ""
   Private cCabURLGov  := cURLTest

   Default aCatalogos  := {}

   GetRemoteType(@cLib)
   If 'HTML' $ cLib
      If IsMemVar("lCP400Auto") .And. !lCP400Auto
         easyhelp(STR0099,STR0021,STR0100) // "Integra��o com Portal �nico n�o dispon�vel no smartclientHtml","Utilizar o smartclient aplicativo"
      Endif
   Else

      begin sequence

         // Caso n�o receba par�metro faz a inclus�o do registro posicionado 
            if len(aCatalogos) == 0
               cVers�oEKD := CPGetVersion(xFilial("EKD"),EK9->EK9_COD_I)
               if ! empty(cVers�oEKD) .and. EKD->(dbsetorder(1),msseek(xFilial("EKD")+EK9->EK9_COD_I+cVers�oEKD))
                  If EKD->EKD_STATUS $ "2|4|5"
                     aadd(aCatalogos, EKD->(recno()) )
                  Else
                     EasyHelp( StrTran(STR0070,"######",EK9->EK9_COD_I),STR0021) //"Cat�logo ###### com status igual a Integrado ou Cancelado n�o pode ser integrado" //Aviso
                     lRet := .F.
                     break
                  EndIf
               endif
            endif

            if ! lIntgProd 
               // se n�o for execauto exibe a pergunta se n�o segue como sim
               if IsMemVar("lCP400Auto") .And. !lCP400Auto .and. ;
                  ! msgnoyes( STR0051 + ENTER ; // "O sistema est� configurado para integra��o com a Base de Testes do Portal �nico."
                           + STR0052 + ENTER ; // "Qualquer integra��o para a Base de Testes n�o ter� qualquer efeito legal e n�o deve ser utilizada em um ambiente de produ��o."
                           + STR0053 + ENTER ; // "Para integrar com a Base Oficial (Produ��o) do Portal �nico, altere o par�metro 'MV_EEC0054' para 1."
                           + STR0054 , STR0002 ) // "Deseja Prosseguir?" // "Aten��o"
                     lRet := .F.
                     break
               else
                  cCPPathAuth := cURLTest+cURLAuth
                  cPathIACP   := cURLTest+cURLIACP
               endif
            else
               cCPPathAuth := cURLProd+cURLAuth
               cPathIACP   := cURLProd+cURLIACP
               cCabURLGov  := cURLProd
            endif

            // Caso n�o receba par�metro faz a inclus�o do registro posicionado 
            if len(aCatalogos) == 0
               cVers�oEKD := CPGetVersion(xFilial("EKD"),EK9->EK9_COD_I)
               if ! empty(cVers�oEKD) .and. EKD->(dbsetorder(1),msseek(xFilial("EKD")+EK9->EK9_COD_I+cVers�oEKD))
                  aadd(aCatalogos, EKD->(recno()) )
               endif
            endif

         if ! lCP400Auto
            oProcess := MsNewProcess():New({|lEnd| aRetIntCP := CP400Sicomex(aCatalogos,cCPPathAuth,cPathIACP,oProcess,lEnd,@cErros) },;
                     STR0055 , STR0056 ,.T.) // "Integrar Cat�logo de Produtos" , "Processando integra��o"
            oProcess:Activate()
         else
            aRetIntCP := CP400Sicomex(aCatalogos,cCPPathAuth,cPathIACP,oProcess,.F.,@cErros)
         endif

         if !Empty(cErros) .and. !aRetIntCP[1]
            // Help(,,"HELP","Aten��o", cErros,1,0)
            EECView(cErros,STR0049) // Falha de integra��o
            lRet := .F.
         ElseIf aRetIntCP[1]
            If aRetIntCP[2]
               If !lCP400Auto
                  MsgInfo(STR0047,STR0021) //"Integrado com sucesso" //"Aviso"               
               Else
                  EasyHelp(STR0047,STR0021) //"Integrado com sucesso" //"Aviso"      
               EndIf  
               lRet := .T. 
            Else
               If !lCP400Auto
                  MsgInfo(STR0089 + ENTER + STR0092 ,STR0021) //"Produto integrado com sucesso no cat�logo, por�m possui pend�ncias entre fabricantes ou pa�ses de origem relacionados!"          //"Aviso"               
               Else
                  EasyHelp(STR0089 + ENTER + STR0092 ,STR0021) //"Produto integrado com sucesso no cat�logo, por�m possui pend�ncias entre fabricantes ou pa�ses de origem relacionados!"          //"Aviso"               
               EndIf
               lRet := .T.   
            EndIf                                           //"Consulte na rotina de integra��o do cat�logo de produtos o log de erro gerado para a �ltima vers�o de integra��o do produto!"
         endif

      end sequence
   endif

Return lRet

/*/{Protheus.doc} CP400Sicomex
   Fun��o que realiza a integra��o com o siscomex para cada item do array aCatalogos
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Function CP400Sicomex(aCatalogos,cCPPathAuth,cPathIACP,oProcess,lEnd,cErros)
   Local cRet           := ""
   Local cAux           := ""
   Local cPerg          := ""
   Local cCodigo        := ""
   Local cChaveEKI      := ""
   Local cChaveEKE      := ""
   Local cSucesso       := ""
   Local ctxtJson       := ""
   Local cJsonAtt       := ""
   Local cModalidade    := ""
   Local cCodinterno    := ""

   Local aJson          := {}
   Local aJsonErros     := {}
   Local aOperadores    := {}

   Local lRet           := .T.
   Local nj
   Local nCP
   Local nContCP        := 0
   Local nQtdInt        := len(aCatalogos)

   Local oJson
   Local oEasyJS

   Local xRetJson
   Local lIntFbrPsO     := .T.
   Local aRet           := {lRet,lIntFbrPsO}
   Local lEKI           :=.F.

      begin sequence
         // se n�o for execauto alimenta reguas de processamento
         if ! lCP400Auto
            oProcess:SetRegua1(nQtdInt)
         endif

         // percorre o array de cat�logos a serem entregados
         for nCP := 1 to nQtdInt
            
            //houve cancelamento do processo
            If lEnd
               lRet := .F.
               break
            EndIf
            
            // posiciona na capa do integrador
            EKD->(dbgoto(aCatalogos[nCP]))
            EK9->(dbsetorder(1),msseek(xFilial("EK9")+EKD->EKD_COD_I))
            // se for diferente de registrado e bloqueado
            If EKD->EKD_STATUS $ "2|4|5"

               // se n�o for execauto alimenta reguas de processamento
               if ! lCP400Auto
                  oProcess:IncRegua1( STR0086 + alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO) ) // "Integrando:"
                  oProcess:SetRegua2(1)
               endif

               // valida��o dos operadores estrangeiros se est�o cadastrados e registrados
               if CP400VldOE(@cErros,@cPerg,@aOperadores)

                  // se houver operador estrangeiro no cat�logo de produtos e n�o no integrador aborta a integra��o
                  if ! empty(cErros)
                     lRet := .F.
                     break
                  endif

                  // caso tenha operadores que ainda n�o estejam integrados com portal �nico 
                  if ! empty(cPerg) .and. len(aOperadores) > 0
                     // � perguntado se deseja o envio dos mesmos, caso n�o aborta integra��o do cat�logo
                     if IsMemVar("lCP400Auto") .And. !lCP400Auto .And. !MsgNoYes( STR0057 + ENTER ; //"Os operadores estrangeiros abaixo n�o est�o integrados"  
                           + cPerg ;
                           + STR0058 , STR0002 ) // "Deseja integrar agora?" // "Aten��o"
                              lRet := .F.
                              break
                     else
                        lOE400Auto := .F.
                        if !OE400Integrar(aOperadores,.T.)
                           lRet := .F.
                           break
                        endif
                     endif
                  endif
               endif

               if EKD->EKD_MODALI == "1" // =Importacao
                  cModalidade := "IMPORTACAO"
               elseif EKD->EKD_MODALI == "2" // =Exportacao
                  cModalidade := "EXPORTACAO"
               elseif empty(EKD->EKD_MODALI) .or. EKD->EKD_MODALI == "3" // =Ambos
                  cModalidade := "AMBOS"
               endif

               //NCF - 08/05/2021 - Altera��o na forma de envio dos fabricantes.
               /*
               // posiciona no primeiro fabricante relacionado para validar montagem do json
               if EKB->(dbsetorder(1),msseek(xFilial("EKB") + EKD->EKD_COD_I))
                  // caso tenha fabricante o fabricante conhecido ser� enviado como true
                  cFabrConhecido := "true"

                  cChaveEKJ := xFilial("EKJ") + EKD->EKD_CNPJ + EKB->EKB_CODFAB + EKB->EKB_LOJA
                  if EKJ->(dbsetorder(1),msseek(cChaveEKJ))
                     // se o pa�s origem do fabricante for brasil manda o cnpj do cadastro do fabricante 
                     cPaisOrigem := EKJ->EKJ_PAIS
                     if cPaisOrigem == "BR"
                        SA2->(dbsetorder(1),msseek(xFilial("SA2") + EKB->EKB_CODFAB + EKB->EKB_LOJA))
                        cCpfCnpjFabric := SA2->A2_CGC
                        cCodigoOE      := ""
                     else // se o pais origem for diferente de brasil manda o c�digo do operador estrangeiro
                        cCodigoOE      := EKJ->EKJ_TIN
                        cCpfCnpjFabric := ""
                     endif
                  endif
               else // caso n�o tenha fabricante ser� enviado como false
                  cFabrConhecido := "false"
               endif
               */

               // Monta o texto do json para a integra��o
               ctxtJson := '[{ "seq": '                 + "1"                    + ' ,'
               // opcional, caso esteja em branco � inclus�o e n�o deve ser enviado, depois de preenchido � altera��o
               if ! empty(EKD->EKD_IDPORT)
                  ctxtJson += ' "codigo": "'             + EKD->EKD_IDPORT        + '" ,'
               endif
               
               ctxtJson += ' "descricao": "'                + alltrim(strtran(EK9->EK9_DSCCOM, chr(13)+chr(10), " ")) + '",' + ;
                           ' "cpfCnpjRaiz": "'              + EKD->EKD_CNPJ          + '",' + ;
                           ' "situacao": "'                 + "ATIVADO"              + '",' + ;
                           ' "modalidade": "'               + cModalidade            + '",' + ;
                           ' "ncm": "'                      + EKD->EKD_NCM           + '",'

               //NCF - 08/05/2021 - Altera��o na forma de envio dos fabricantes.
               /*
                           ' "paisOrigem": "'               + cPaisOrigem            + '",' + ;
                           ' "fabricanteConhecido": '       + cFabrConhecido         + ' ,'
               
               // define o fabricante caso exista 
               if cFabrConhecido == "true"
                  if cPaisOrigem == "BR"
                     ctxtJson += ' "cpfCnpjFabricante": "'         + cCpfCnpjFabric   + '",' 
                  else
                     ctxtJson += ' "codigoOperadorEstrangeiro": "' + cCodigoOE        + '",' 
                  endif
               endif
               */

               // percorre os atributos cadastrados para o cat�logo de produto enviando atributo e valor
               cChaveEKI := xFilial("EKI") + EKD->EKD_COD_I + EKD->EKD_VERSAO
               if EKI->(dbsetorder(1),msseek(cChaveEKI))
                  lEKi := .T.
                  cJsonAtt := ' "atributos": [ '
                     while EKI->(! eof()) .and. EKI->(EKI_FILIAL+EKI_COD_I+EKI_VERSAO) == cChaveEKI
                        if ! empty(EKI->EKI_VALOR)
                           
                           nContCP++
                           if nContCP > 1
                              cJsonAtt += ','
                           endif

                           cJsonAtt += '{' + ;
                                          ' "atributo": "' + EKI->EKI_CODATR                                          + '",' + ;
                                          ' "valor": "'    + alltrim(strtran(EKI->EKI_VALOR, chr(13)+chr(10), " "))   + '" ' + ;
                                       '}'
                        endif
                        EKI->(dbskip())
                     enddo
                  cJsonAtt += ']'
                  ctxtJson += cJsonAtt
                  nContCP := 0
               endif

               // percorre a lista de c�digo relacionados que s�o enviados em lista
               cChaveEKE := xFilial("EKE") + EKD->EKD_COD_I + EKD->EKD_VERSAO
               if EKE->(dbsetorder(1),msseek(cChaveEKE))
                  cCodinterno := if(lEKi,',','') +' "codigosInterno": [ '
                     while EKE->(! eof()) .and. EKE->(EKE_FILIAL+EKE_COD_I+EKE_VERSAO) == cChaveEKE

                        nContCP++
                        if nContCP > 1
                           cCodinterno += ','
                        endif

                        cCodinterno += '"' + EKE->EKE_PRDREF + '"'

                        EKE->(dbskip())
                     enddo
                  cCodinterno += ']'
                  ctxtJson += cCodinterno
                  nContCP := 0
               endif
               ctxtJson +=   '}' + ;
                        ']'

               // consome o servi�o atrav�s do easyjs
               oEasyJS  := EasyJS():New()
               oEasyJS:cUrl := cCPPathAuth
               oEasyJS:Activate(.T.)
               oEasyJS:runJSSync( CP400Auth( cCPPathAuth , cPathIACP , ctxtJson ) ,{|x| cRet := x } , {|x| cErros := x } )

               // Pega o retorno e converte para json para extrair as informa��es
               if ! empty(cRet) .and. empty(cErros)
                  cRet     := '{"items":'+cRet+'}'
                  oJson    := JsonObject():New()
                  xRetJson := oJson:FromJson(cRet)
                  if valtype(xRetJson) == "U" 
                     if valtype(oJson:GetJsonObject("items")) == "A"
                        aJson    := oJson:GetJsonObject("items")
                        if len(aJson) > 0
                           cSucesso := aJson[1]:GetJsonText("sucesso")
                           cCodigo  := aJson[1]:GetJsonText("codigo")
                           if valtype(aJson[1]:GetJsonObject("erros")) == "A"
                              aJsonErros := aJson[1]:GetJsonObject("erros")
                              for nj := 1 to len(aJsonErros)
                                 cErros += aJsonErros[nj] + ENTER
                              next
                              if empty(cErros)
                                 cErros += STR0060
                              endif
                           endif
                        endif
                     else
                        cErros += STR0059 + ENTER // "Arquivo de retorno sem itens!"
                     endif
                     FreeObj(oJson)
                  else
                     // cErros += STR0060 + ENTER // "Arquivo de retorno inv�lido!"
                     cErros += STR0071 + ENTER + alltrim(cRet) // "N�o foi poss�vel fazer o parse do JSON de retorno da integra��o."
                  endif
               elseif ! empty(cErros)
                  if match(cErros,"*Failed to fetch*")
                     cErros := STR0072 + ENTER // "N�o foi poss�vel estabelecer conex�o com o portal �nico. Verifique se est� conectado na internet ou se o certificado est� correto."
                  endif
               elseif empty(cErros)
                  cErros += STR0061 + ENTER // "Integra��o sem nenhum retorno!"
               endif

               // caso d� tudo certo grava as informa��es e finaliza o registro
               if ! empty(cRet) .and. ! empty(cSucesso) .and. upper(cSucesso) == "TRUE"

                     //NCF - 08/05/2021 - Realiza a integra��o de Fabricantes/Pa�s de Origem
                     cPathIFbPO := cCabURLGov + cURLIFbrPO
                     if !lCP400Auto
                        oProcIntFb := MsNewProcess():New({|lEnd| lIntFbrPsO := CP400IFbPO(cCPPathAuth,cPathIFbPO,oProcIntFb,lEnd,@cErros,oEasyJS) }, STR0085 , STR0056 ,.T.) // "Integrar Fabricante" , "Processando integra��o"
                        oProcIntFb:Activate()
                     else
                        lIntFbrPsO := CP400IFbPO(cCPPathAuth,cPathIFbPO,oProcIntFb,.F.,@cErros,oEasyJS)
                     endif
                     cStIntCP   := If( lIntFbrPsO , "1" , "5" )  // 5-Registrado (pendente: fabricante/ pa�s)
                     If(!lIntFbrPsO , aRet[2] := lIntFbrPsO , )  // Indicar erro na integra��o de fabrincantes/pa�s em uma das integra��es de produto.

                     reclock("EKD",.F.)
                     EKD->EKD_STATUS   := cStIntCP
                     EKD->EKD_IDPORT   := cCodigo
                     EKD->EKD_DATA     := dDatabase
                     EKD->EKD_HORA     := strtran(time(),":","")
                     EKD->EKD_USERIN   := __cUserID
                     EKD->EKD_RETINT   := If( cStIntCP == "5", STR0091 + ENTER + Alltrim(cErros)  ,"") //"Erros de retorno da integra��o de Fabricantes/Pa�ses de Origem relacionados ao produto integrado:"
                     EKD->(msunlock())

                  // grava o status de registrado do cat�logo de produtos
                  reclock("EK9",.F.)
                     EK9->EK9_STATUS   := "1"
                     EK9->EK9_IDPORT   := cCodigo
                     EK9->EK9_VATUAL   := EKD->EKD_VERSAO
                     EK9->EK9_RETINT   := ""
                  EK9->(msunlock())

                  if ! lCP400Auto
                     oProcess:IncRegua2( STR0062 ) // "Integrado!"
                     oProcess:IncRegua2( STR0062 ) // "Integrado!"
                  endif
               else // caso n�o grava o log, se n�o tiver ret tem algum erro.
                  lRet := .F.
                  cErros := "Erro ao integrar em " + dtoc(dDatabase) + " as " + time() + ENTER + cErros + ENTER
                  cErros := "Produto/Vers�o: " + alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO) + ENTER + cErros + ENTER
                  reclock("EKD",.F.)
                     EKD->EKD_STATUS   := "4"
                     // EKD->EKD_DATA     := dDatabase
                     // EKD->EKD_HORA     := strtran(time(),":","")
                     EKD->EKD_USERIN   := __cUserID
                     EKD->EKD_RETINT   := cErros
                     EKD->(msunlock())

                     // grava o status de falha do cat�logo de produtos
                     reclock("EK9",.F.)
                     EK9->EK9_RETINT   := cErros
                  EK9->(msunlock())

                  if ! lCP400Auto
                     oProcess:IncRegua2( STR0063 ) // "Falha!"
                     oProcess:IncRegua2( STR0063 ) // "Falha!"
                  endif
               endif
            endif
            
            cAux += cErros + ENTER
            cErros   := ""
            cRet     := ""
            cCodigo  := ""
            cSucesso := ""
         next
      end sequence

      aRet[1] := lRet

      if ! empty(cAux)
         cErros := cAux
      endif

Return aClone(aRet)

/*/{Protheus.doc} CP400Auth
   Gera o script para autenticar e consumir o servi�o do portaul unico atrav�s do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Static Function CP400Auth(cUrl,cPathIACP,cOperador)
   Local cVar

   begincontent var cVar
      fetch( '%Exp:cUrl%', {
         method: 'POST',
         mode: 'cors',
         headers: { 
            'Content-Type': 'application/json',
            'Role-Type': 'IMPEXP',
         },
      })
      .then( response => {
         if (!(response.ok)) {
            throw new Error( response.statusText );
         }
         var XCSRFToken = response.headers.get('X-CSRF-Token');
         var SetToken = response.headers.get('Set-Token');
         return fetch( '%Exp:cPathIACP%', {
            method: 'POST',
            mode: 'cors',
            headers: { 
               'Content-Type': 'application/json',
               "Authorization": SetToken,
               "X-CSRF-Token":  XCSRFToken,
            },
            body: '%Exp:cOperador%'
         })
      })
      .then( (res) => res.text() )
      .then( (res) => { retAdvpl(res) } )
      .catch((e) => { retAdvplError(e) });
   endcontent

Return cVar

/*
Programa   : CP400VldOE
Objetivo   : validar se no cadastro de operador estrangeiro o mesmo est� integrado ao portal �nico
           : e se o operador est� registrado no integrador do cat�logo de produtos
Retorno    : lRet
Autor      : Miguel Prado Gontijo
Data/Hora  : 21/07/2020
Obs.       :
*/
Function CP400VldOE(cErros,cPerg,aOperadores)
   Local aAreaEKB    := EKB->(getarea())
   Local aAreaEKJ    := EKJ->(getarea())
   Local cChaveEKB   := ""
   Local cChaveEKJ   := ""
   Local nContOE     := 0
   Local lRet        := .F.
   Local lEkbPAis    :=EKB->(FieldPos("EKB_PAIS")) > 0

   // posiciona nos fabricantes relacionados ao cat�logo de produtos
   cChaveEKB := xFilial("EKB") + EKD->EKD_COD_I
   if EKB->(dbsetorder(1),msseek(cChaveEKB))
      // enquanto houverem fabricantes/pais de origem relacionados a esse cat�logo de produtos 
      while EKB->( ! eof() ) .and. EKB->EKB_FILIAL+EKB->EKB_COD_I == cChaveEKB

         // verifica se o operador estrangeiro est� cadastrado 
         cChaveEKJ := xFilial("EKJ") + EKD->EKD_CNPJ + EKB->EKB_CODFAB + EKB->EKB_LOJA
         if !empty(EKB->EKB_CODFAB) .And. EKJ->(dbsetorder(1),msseek(cChaveEKJ))  //NCF - 08/05/2021 - Fabricante deve estar informado para integraro o operador(se existir)
            
            // verifica se o mesmo est� integrado ao portal �nico
            if EKJ->EKJ_STATUS <> "1" .And. !Empty(EKB->EKB_CODFAB)
               cPerg += strtran( STR0064 , "XXXX" , alltrim(EKJ->EKJ_FORN) + "/" + alltrim(EKJ->EKJ_FOLOJA)) + ENTER // STR0064 - "Fabricante XXXX n�o integrado!"
               // adciona o operador para realizar a integra��o com portal �nico
               aadd( aOperadores, EKJ->(recno()))
            endif
         else
            // NCF - 08/02/2021 - verifica se possui o pa�s de origem cadastrado, pois se tiver n�o precisa ter o cadastro de operador estrangeiro.
            if !lEkbPAis /* EKB->(FieldPos("EKB_PAIS"))==0 */ .Or. Empty(EKB->EKB_PAIS)
               nContOE++
               // caso seja o primeiro registro insere informa��o do produto e vers�o a relatar o problema
               if nContOE == 1
                  cErros += strtran(  STR0065 , "XXXX" , alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO)) + ENTER // "Produto/Vers�o: XXXX "
               endif
               cErros += strtran(  STR0066 , "XXXX" , alltrim(EKB->EKB_CODFAB)  + "/" + alltrim(EKB->EKB_LOJA)) + ENTER // "Fabricante/Loja XXXX n�o registrado como operador estrangeiro!"
            endif
         endif
 
         EKB->(dbskip())
      enddo
   endif

   lRet := ! empty(cErros) .or. (! empty(cPerg) .and. len(aOperadores) > 0)

   restarea(aAreaEKB)
   restarea(aAreaEKJ)

Return lRet
/*{Protheus.doc} CPGetVersion
   Busca a �ltima vers�o do integrador do cat�logo de produtos
   @author Miguel Prado Gontijo
   @since 20/06/2020
   @version 1
   @param cFilial e cXCodI - Filial e c�digo do item a ser buscado a �ltima vers�o
   @return Nil
*/
function CPGetVersion( cXFil , cXCodI )
   Local cRet := ""

   if select("EKDVERSAO") > 0
      EKDVERSAO->(dbclosearea())
   endif

   BeginSql Alias "EKDVERSAO"
      select MAX(EKD_VERSAO) VERSAO 
      from %table:EKD% EKD 
      where EKD_FILIAL  = %Exp:cXFil%
         and EKD_COD_I  = %Exp:cXCodI%
         and EKD.%NotDel%
   EndSql

   EKDVERSAO->(dbgotop())
   if EKDVERSAO->(! eof())
      cRet := EKDVERSAO->VERSAO
   endif
   EKDVERSAO->(dbclosearea())

Return cRet
/*
Programa   : CP400CadOE
Objetivo   : Inserir registros no cadastro de operador estrangeiro
Retorno    : 
Autor      : Maur�cio Frison
Data/Hora  : 10/06/2020
Obs.       :
*/
Function CP400CadOE()
   Local oModel      := FWLoadModel("EICCP400")
   Local oModelEKB   := oModel:GetModel("EKBDETAIL")
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local aOEs        := {}
   Local lRet := .t.

   oModel:Activate()
   if CP400OEValid(oModelEKB,oModelEK9,@aOEs)
      lRet := CP400ExecEKJ(aOEs,oModelEK9)
      oModel:activate()
   Else 
         EasyHelp( StrTran(STR0069,"######",EK9->EK9_COD_I),STR0021) //Aviso Nenhum registro para processar. Todos os fabricantes do cat�logo ###### j� se encontram no cadastro de operador estrangeiro
   endif

Return
/*
Programa   : CP400OEValid
Objetivo   : Funcao que valida se deve gerar o cadastro de operador estrangeiro a partir do cadastro de fabricante relacionado ao produto do cat�logo
Retorno    : L�gico
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
static function CP400OEValid(oModelEKB,oModelEK9,aOEs)
   Local lRet        := .F.
   Local nLinEKB     := 1
   Local cChaveEKJ2  := ""
   Local aAux        := {}
   Local aAreaEKJ    := EKJ->(getarea())

   for nLinEKB := 1 to oModelEKB:length()
      if ! oModelEKB:isdeleted(nLinEKB)
         if ! empty( oModelEKB:getvalue("EKB_CODFAB", nLinEKB) ) .and. ! empty( oModelEKB:getvalue("EKB_LOJA", nLinEKB) )
            cChaveEKJ2 := xFilial("EKJ") + AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R") + oModelEKB:getvalue("EKB_CODFAB", nLinEKB)  + oModelEKB:getvalue("EKB_LOJA", nLinEKB)
            if ! EKJ->(dbsetorder(1),msseek(cChaveEKJ2))
               aAux := {}
               Aadd( aAux, { "EKJ_FILIAL"  , xFilial("EKJ")                            , Nil })
               Aadd( aAux, { "EKJ_IMPORT"  , oModelEK9:GetValue("EK9_IMPORT")          , Nil })
               Aadd( aAux, { "EKJ_CNPJ_R"  , AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R"), Nil })
               Aadd( aAux, { "EKJ_FORN"    , oModelEKB:getvalue("EKB_CODFAB" , nLinEKB) , Nil })
               Aadd( aAux, { "EKJ_FOLOJA"  , oModelEKB:getvalue("EKB_LOJA"   , nLinEKB) , Nil })
               aadd( aOEs, aclone(aAux))
            endif
         endif
      endif
   next

   lRet := len(aOEs) > 0

   restarea(aAreaEKJ)
return lRet


/*
Programa   : CP400ExecEKJ(aOEs)
Objetivo   : ExecAuto de Operador Estrangeiro - Grava o fabricante na tabela de operador estrangeiro
Par�metro  : aOEs - array que cont�m uma lista de operadores a serem inclu�dos via rotina autom�tica
Retorno    : Nil
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
function CP400ExecEKJ(aOEs,oModelEK9)
   Local aArea       := getarea()
   Local aLog        := {}
   Local i           := 0
   Local nx          := 0
   Local nPosForn    := ""
   Local nPosFoLoja  := ""
   Local cMsg        := ""
   Local lRet        := .T.

   Private lMsErroAuto     := .F.
   Private lAutoErrNoFile  := .T.
   Private lMsHelpAuto     := .F. 

   For i := 1 to len(aOEs)
      lMsErroAuto := .F.
      MsExecAuto({|x,y| EICOE400(x,y) },aOEs[i], 3)
      if lMsErroAuto
         lRet := .F.
         aLog        := GetAutoGrLog()
         nPosForn    := ascan(aOEs[i], {|x| x[1] == "EKJ_FORN" })
         nPosFoLoja  := ascan(aOEs[i], {|x| x[1] == "EKJ_FOLOJA" })
         cMsg        += STR0074 + alltrim(oModelEK9:getvalue('EK9_COD_I')) + ENTER //"Erro na inclus�o do registro de operador estrangeiro para o cat�logo "
         cMsg        += STR0077 + Alltrim(aOEs[i][nPosForn][2]) + " Loja: " + Alltrim(aOEs[i][nPosFoLoja][2]) + ENTER //"Fornecedor: "
         cMsg        += STR0078 + ENTER //"Esse erro n�o intefere na grava��o do cat�logo de produtos(Veja mensagem abaixo)"
         for nx := 1 to len(aLog)
            cMsg += Alltrim(aLog[nx]) + ENTER
         Next
      EndIf
   Next

   if ! empty(cMsg)
      EECVIEW(cMsg, STR0002)
   endif

   restarea(aArea)

return lRet
/*
Programa   : ExcIntegr
Objetivo   : Funcao utilizada para excluir integra��o do cat�logo de produtos N�o Integrada
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function ExcIntegr( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 5)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CancInteg
Objetivo   : Funcao utilizada para Cancelar integra��o do cat�logo de produtos
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function CancInteg( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 4)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CP400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Ramon Prado
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP400Legen()
   Local aCores := {}

   aCores := {	{"ENABLE"      , STR0004   },; // "Registrado"
               {"BR_CINZA"    , STR0005   },; // "Pendente Registro"
               {"BR_AMARELO"  , STR0006   },; // "Pendente Retifica��o"
               {"DISABLE"     , STR0007   }}  // "Bloqueado"

   BrwLegenda(STR0001,STR0013,aCores)

Return .T.
/*
Fun��o     : GetVisions()
Objetivo   : Retorna as vis�es definidas para o Browse
*/
Static Function GetVisions()
   Local aVisions    := {}
   Local aColunas    := AvGetCpBrw("EK9")
   Local aContextos  := {"REGISTRADO", "PENDENTE_REGISTRO", "PENDENTE_RETIFICACAO", "BLOQUEADO"} // {STR0004,STR0005,STR0006,STR0007}
   Local cFiltro     := ""
   Local oDSView
   Local i

   If aScan(aColunas, "EK9_FILIAL") == 0
      aAdd(aColunas, "EK9_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := RetFilter(aContextos[i])            
      oDSView    := FWDSView():New()
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
Fun��o     : RetFilter(cTipo,lNome)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Par�metros : cTipo - C�digo do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
   Local cRet     := ""
   Default lNome  := .F.

      Do Case
         Case cTipo == "REGISTRADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '1' "
         Case cTipo == "REGISTRADO" .And. lNome
            cRet := STR0004 //"Registrado" "

         Case cTipo == "PENDENTE_REGISTRO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '2' "
         Case cTipo == "PENDENTE_REGISTRO" .And. lNome
            cRet := STR0005 //"Pendente Registro" "

         Case cTipo == "PENDENTE_RETIFICACAO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '3' "
         Case cTipo == "PENDENTE_RETIFICACAO" .And. lNome
            cRet := STR0006 //"Pendente Retifica��o" "

         Case cTipo == "BLOQUEADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '4' "
         Case cTipo == "BLOQUEADO" .And. lNome
            cRet := STR0007 //"Bloqueado"
      EndCase

Return cRet

/*
Fun��o     : CP400SB1F3()
Objetivo   : Monta a consulta padr�o da filial de origem do produto para sele��o 
             
Par�metros : Nenhum
Retorno    : lRet
Autor      : Ramon Prado (adaptada da fun��o NF400SD2F3, fonte: EICCP400)
Data       : Dez/2019
Revis�o    :
*/
Function CP400SB1F3()
   Local aSeek    := {}
   Local bOk      := {|| lRet:= .T., oDlg:End()}
   Local bCancel  := {|| lRet:= .F.,  oDlg:End()}
   Local cCpo     := AllTrim(Upper(ReadVar()))
   Local aColunas	:= IF(cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF", AvGetCpBrw("SB1",,.T. /*desconsidera virtual*/), AvGetCpBrw("SA2",,.T. /*desconsidera virtual*/))
   Local lRet     := .F.
   Local nX       := 1
   Local oDlg
   Local oBrowse

   Private cTitulo   := ""
   Private aCampos   := {}
   Private aFilter   := {} 

   Begin Sequence
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aAdd(aColunas,"B1_IMPORT")
      Elseif cCpo == "M->EKB_CODFAB" .And. aScan(aColunas, "A2_FILIAL") == 0      
         aAdd(aColunas,Nil)
         AIns(aColunas,1)
         aColunas[1] := "A2_FILIAL"    
      EndIf   
      
      /* Campos usados na pesquisa */
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aSeek := AVIndSeek("SB1",3)
      Else
         aSeek := AVIndSeek("SA2",3)
      EndIf

      For nX := 1 to Len(aColunas)
         /* Campos usados no filtro */
         AAdd(aFilter, {aColunas[nX]  , AvSx3(aColunas[nX]    , AV_TITULO) , AvSx3(aColunas[nX]    , AV_TIPO) , AvSx3(aColunas[nX]    , AV_TAMANHO) , AvSx3(aColunas[nX]    , AV_DECIMAL), AvSx3(aColunas[nX]    , AV_PICTURE)})
      Next nX
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         AllCpoIndex("SB1",aColunas)
         cTitulo := STR0016
      Else
         AllCpoIndex("SA2",aColunas)
         cTitulo := STR0035
      EndIf
      
      Define MsDialog oDlg Title STR0001 + " - " + cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel

      oBrowse:= FWBrowse():New(oDlg)
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         oBrowse:SetDataTable("SB1")
         oBrowse:SetAlias("SB1")
         //cTitulo := STR0016
         oBrowse:SetColumns(AddColumns(aColunas, "SB1"))
      Else
         oBrowse:SetDataTable("SA2")
         oBrowse:SetAlias("SA2")
         //cTitulo := STR0035
         oBrowse:SetColumns(AddColumns(aColunas, "SA2"))
      EndIf

      oBrowse:bLDblClick:= {|| lRet:= .T.,  oDlg:End()}

      //oBrowse:SetDescription(cTitulo) 

      /* Pesquisa */
      oBrowse:SetSeek(, aSeek)
      
      /* Filtro */	
      oBrowse:SetUseFilter()
      oBrowse:SetFieldFilter(aFilter)
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         oBrowse:AddFilter('Default',"SB1->B1_IMPORT == 'S' .And. SB1->B1_MSBLQL <> '1' ",.F.,.T.)
      EndIf   

      If cCpo == "M->EKA_PRDREF" .And. !Empty(M->EK9_NCM)
         oBrowse:AddFilter('Ncm',"SB1->B1_POSIPI == '"+M->EK9_NCM+"' ",.F.,.T.)
      EndIF

      oBrowse:Activate()
      
      Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	

   End Sequence

Return lRet

/*
Fun��o     : CP400Relac(cCampo)
Objetivo   : Inicializar dados dos campos do grid(Relacao de Produtos - Catalogo de prds)
Par�metros : cCampo - campo a ser inicializado
Retorno    : cRet - Conteudo a ser inicializado
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400Relac(cCampo)
   Local aArea       := getArea()
   Local cRet        := "" 
   Local oModel      := FWModelActive()
   Local oModelEKA   := oModel:GetModel("EKADETAIL")
   Local cChaveEKJ   := ""
   Local cChaveEKJ2   := ""
   Local cChaveSA2   := ""

   If oModel:GetOperation() <> 3

      Do Case
         Case cCampo == "EKA_DESC_I" .And. ValType(oModelEKA) == "O"
            If lMultiFil
               cRet := Posicione("SB1",1,EKA->EKA_FILORI+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC")
            Else
               cRet := Posicione("SB1",1,XFILIAL("SB1")+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC")
            EndIf
         Case cCampo == "EK9_DESC_I"
            If lMultiFil
               cRet := POSICIONE("SB1",1,FWFLDGET("EK9_FILORI")+FWFLDGET("EK9_PRDREF"),"B1_DESC")
            Else		
               cRet := POSICIONE("SB1",1,XFILIAL("SB1")+FWFLDGET("EK9_PRDREF"),"B1_DESC")
            EndIf
         Case cCampo == "EKB_NOME"
            If lMultiFil
               cRet := POSICIONE("SA2",1,EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            Else
               cRet := POSICIONE("SA2",1,EKB->EKB_FILIAL+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            EndIf
         Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"
            If lMultiFil
               cChaveSA2 := EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA
            Else
               cChaveSA2 := EKB->EKB_FILIAL+EKB->EKB_CODFAB+EKB->EKB_LOJA
            EndIf
            if SA2->(dbsetorder(1),msseek(cChaveSA2))
               cChaveEKJ := SA2->A2_FILIAL+EK9->EK9_CNPJ+SA2->A2_COD+SA2->A2_LOJA
               EKJ->(dbsetorder(1))
               if EKJ->(msseek(cChaveEKJ)) .Or. EKJ->(msseek(cChaveEKJ2))
                  if cCampo == "EKB_OENOME"
                     cRet := EKJ->EKJ_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := EKJ->EKJ_STATUS
                  elseif ccampo == "EKB_OPERFB"
                     cRet := EKJ->EKJ_TIN
                  endif
               else
                  if cCampo == "EKB_OENOME"
                     cRet := SA2->A2_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := "2"
                  endif
               endif
            endif
         Case cCampo == "EKB_PAISDS"
            cRet := POSICIONE("SYA",1,xFilial("SYA")+EKB->EKB_PAIS,"YA_DESCR")
         Case cCampo == "EKC_STATUS"
            EKG->(dbSetOrder(1))
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR))
               cRet := CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG)
            EndIf
         Case cCampo == "EKC_NOME"
            EKG->(dbSetOrder(1))
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR))
               cRet :=if(EKG->EKG_OBRIGA == "1","* ","") + AllTrim(EKG->EKG_NOME)
            EndIf
         Case cCampo == "EKC_VLEXIB"
            //cRet := IIF(!Empty(EKC->EKC_VALOR),SubSTR(EKC->EKC_VALOR,1,100),"")
                     
      EndCase	
   EndIf

   RestArea(aArea)

Return cRet

/*
Fun��o     : CP400When(cCampo)
Objetivo   : Define se campo ser� habilitado para edi�ao/altera��o ou n�o na tela
Par�metros : cCampo - campo a verificado o when(ser� habilitado pra edi��o/altera��o ou nao na tela)
Retorno    : lWhen - l�gico sim ou nao
Autor      : Ramon Prado
Data       : maio/2021
Revis�o    :
*/
Function CP400When(cCampo)
   Local aArea       := getArea()
   Local lWhen       := .T.

   Do Case
      Case cCampo == 'EKB_PAIS'
         If !Empty(Fwfldget("EKB_CODFAB")) .and. !EMPTY(Fwfldget("EKB_LOJA"))
            lWhen := .F.
         EndIf
      Case cCampo == 'EK9_MSBLQL'   //MFR 14/02/2022 OSSME-6604        
            lWhen := !Inclui
   EndCase

   RestArea(aArea)
Return lWhen

/* 
Fun��o     : CP400AtLn1()
Objetivo   : Gatilho para preencher produto de refer�ncia na linha 1 do detalhe(Relacao de produtos)
Par�metros : 
Retorno    : cRet - Conteudo a ser gatilhado
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400AtLn1()	
   Local aArea       := getArea()	 
   Local oModel      := FWModelActive()
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local oModelEKA   := oModel:GetModel("EKADETAIL")
   Local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   Local nI	         := 1
   Local nPos        := 0
   Local lExistPrd   := .F.
   Local mDesc       := ""

   If oModelEKA:Length() > 0 .And. !Empty(oModelEK9:GetValue("EK9_PRDREF"))	
      For nI := 1 to oModelEKA:Length()
         oModelEKA:GoLine( nI )
         If oModelEKA:GetValue("EKA_PRDREF") == oModelEK9:GetValue("EK9_PRDREF")			
            lExistPrd := .T.
            exit
         Endif
         If Empty(oModelEKA:GetValue("EKA_PRDREF"))
            nPos := nI
         EndIf
      Next nI
      
      If !lExistPrd     
         If nPos > 0
            oModelEKA:GoLine( nPos )
            oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
         Else
            if oModelEKA:Length() < oModelEKA:AddLine()
               oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
               CP400Ncm(oModelEK9,oModelEKA)
            Else
               cRet := oModelEK9:GetValue("EK9_PRDREF")
            EndIf   
         EndIf		
      ElseIf oModelEKA:IsDeleted()
         oModelEKA:UnDeleteLine()		
         oModelEKA:Goline(1) //posiciona na linha 1
      EndIf
      oModelEKA:GoLine(1)	//posiciona na linha 1
   Endif

   If !Empty(oModelEK9:GetValue("EK9_PRDREF"))
      mDesc := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
      If !Empty(mDesc)	
         FwFldPut("EK9_DSCCOM",AvKey(mDesc,"EK9_DSCCOM"))
      EndIf	
   EndIf

   RestArea(aArea)

Return cRet

/*
Fun��o     : CP400Ncm(model)
Objetivo   : Excluir as linhas que tenham o produto com ncm diferente do ncm da capa(EK9)
Par�metros : 
Retorno    : Retorno .t.
Autor      : Maur�cio Frison
Data       : Abr/2020
Revis�o    :
*/
Function CP400Ncm(oModelEK9,oModelEKA)
   Local oView       := FWViewActive()
   Local nI          :=0
   Local cPRod       :=""
   Local cFil        :=""
   Local aArrayProd	:= {}
  // Local lFirstPrd   := .T. // MFR 02/03/2022 OSSME-6595

   if oModelEKA:GetOperation() == 3 //inclusao
      aArrayProd := CP400ArPrd(oModelEKA)
      if len(aArrayProd) > 0
         oModelEKA:ClearData(.T.,.F.) //oModelEKA:ClearData(.T.,.T.) MFR 11/02/2022 OSSME-6595
         FOR nI:=1 TO LEN(aArrayProd)
            cProd := aArrayProd[ni][1]
            cFil  := aArrayProd[ni][2] //if(!lMultiFil,aArrayProd[ni][2],oModelEK9:GetValue("EK9_FILORI")) MFR 02/03/2022 OSSME-6595
            CP400PsFil(cProd,cFil,"SB1")
            If Alltrim(oModelEK9:GetValue("EK9_NCM")) == AllTrim(SB1->B1_POSIPI) // Alltrim(cNCM) == AllTrim(SB1->B1_POSIPI) neste caso o cNCM ainda n�o est� atualizado
               //If !lFirstPrd
                  oModelEKA:AddLine()
               //EndIf               
               oModelEKA:SetValue("EKA_PRDREF", cProd)
    //           lFirstPrd := .F. // MFR 02/03/2022 OSSME-6595
            EndIf
         Next
         IF oModelEKA:Length() == 0 // MFR 11/02/2022 OSSME-6595
            oModelEKA:AddLine()
         EndIf         
         oModelEKA:GoLine(1)
         oview:Refresh("EKADETAIL")         
      EndIf  
   EndIf 

return .T.


/*
Fun��o     : CP400Valid()
Objetivo   : Validar dados digitados nos campos EK9 e EKA
Par�metros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400Valid(cCampo,lUndelete)
   Local oModel         := FWModelActive()
   Local oModelEK9      := oModel:GetModel("EK9MASTER")
   Local oModelEKA      := oModel:GetModel("EKADETAIL")
   Local oModelEKB      := oModel:GetModel("EKBDETAIL")
   Local oModelEKC      := oModel:GetModel("EKCDETAIL")
   Local cChaveEKJ      := ""
   Local lRet           := .T.
   Local lPosicEKD      := .F.
   Local cCodFab        := ""
   Default lUndelete    := .F.


   Do Case
      Case cCampo == "EK9_PRDREF" .OR. cCampo == "EK9_FILORI" .or. cCampo == "EKA_PRDREF" .OR. cCampo == "EKA_FILORI"
         Begin Sequence
            If cCampo == "EK9_PRDREF" .And. Empty(oModelEK9:GetValue("EK9_CNPJ"))  // MFR 11/02/2022 OSSME-6598
               lRet:=.F.
               EasyHelp(STR0104,STR0002,STR0103) //Campo CNPJ n�o informado. Informe primeiro o campo CNPJ Raiz
               break
            EndIf
            If lRet
               cProd := if(cCampo == "EK9_PRDREF", oModelEK9:GetValue("EK9_PRDREF") ,oModelEKA:GetValue("EKA_PRDREF"))         
               cFil  := if(cCampo == "EK9_PRDREF" .or. cCampo == "EKA_PRDREF", NIL, if(cCampo == "EK9_FILORI",M->EK9_FILORI , oModelEKA:GetValue("EKA_FILORI")))         
               If lMultiFil .And. !Empty(cProd)	
                  lRet := CP400PsFil(cProd,cFil,"SB1")
               ElseIf !Empty(cProd)
                  lRet := CP400PsFil(cProd,xFilial("SB1"),"SB1")
               EndIf
            EndIf   

            If lRet
               If SB1->B1_MSBLQL == '1'
                  EasyHelp(STR0019,STR0002) //"'Produto n�o encontrado no cadastro para esta filial'"##"Aten��o"
                  lRet := .F.
               EndIf
            Else
               Help(" ",1,"REGNOIS")
            EndIf
            
            If lRet .And. !Empty(oModelEK9:GetValue("EK9_NCM")) .and. (cCampo=="EKA_PRDREF" .or. cCampo =="EK9_PRDREF")
                  If Alltrim(oModelEK9:GetValue("EK9_NCM")) <> AllTrim(SB1->B1_POSIPI)                     // .T. pega s� as linha v�lidas (n�o deletadas)
                        If oModel:GetOperation() == 4 .or. (oModel:GetOperation() == 3 .And. oModelEKA:Length(!lUndelete) > 1) // 4=altera��o ou 3-Inclus�o e j� tem um ou mais produtos com o ncm igual ao da capa
                           lRet:=.F.
                           easyhelp(STR0042,STR0002,STR0107) //Altera��o n�o permitida porque este produto possui NCM diferente da capa do processo. Informe um produtro com o mesmo NCM
                        Else
                           If cCampo =="EK9_PRDREF" .And. IsMemVar("lCP400Auto") .And. !lCP400Auto .And. MsgNoYes(STR0020,STR0021) //'O Ncm do produto digitado � diferente do Ncm digitado no Cabe�alho. Deseja Prosseguir?'##'Aviso'
                              lRet := .T.
                              If oModelEKC:Length() > 0 .and. !Empty(oModelEKC:GetValue("EKC_CODATR"))
                                 lRet := MsgNoYes(STR0032,STR0002) // "Confirma altera��o do NCM, se confirmar todas as informa��es sobre os atributos ser�o perdidas" ## "Aten��o"
                              EndIf 
/*                           ElseIf IsMemVar("lCP400Auto") .And. !lCP400Auto
                              lRet := .F.*/
                           EndIf	
                           if lRet
                              oModelEK9:LoadValue("EK9_NCM", SB1->B1_POSIPI)
                              CP400ATRIB(.F.)
                           else
                              cNcmAux := oModelEK9:GetValue("EK9_NCM")
                           EndIf
                        EndIf
                  EndIf
            EndIf
         End Sequence   
      Case cCampo == "EKB_LOJA" .Or. cCampo == "EKB_FILORI"

         IF !Empty(oModelEKB:GetValue("EKB_CODFAB"))
            cCodFab := oModelEKB:GetValue("EKB_CODFAB")+oModelEKB:GetValue("EKB_LOJA")
         Else
            Help("",1,"CP400LOJA") //Problema: C�digo do Fabricante n�o est� preenchido Solu��o: Preencha o C�d. do Fabricante
            lRet := .F.  
         EndIf 

         If lRet  
            If cCampo == "EKB_FILORI"
               cFil  := oModelEKB:GetValue("EKB_FILORI")
            EndIf

            If lMultiFil
               If !Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. !Empty(oModelEKB:GetValue("EKB_LOJA"))            
                  cFil := If(empty(oModelEKB:GetValue("EKB_FILORI")),xFilial('SA2'),oModelEKB:GetValue("EKB_FILORI"))
                  lRet := CP400PsFil(cCodFab,cFil,"SA2") //lRet := CP400PsFil(cCodFab,cFil,"SA2")  // MFR 11/02/2022 OSSME-6595                     
               EndIf   
            ElseIf !Empty(cCodFab)
               lRet := CP400PsFil(cCodFab,xFilial("SA2"),"SA2")             
            EndiF
            If !lRet
               Help(" ",1,"REGNOIS")
            EndIf  

            If lRet
               cChaveEKJ := xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA // MFR 11/02/2022 OSSME-6598
               if EKJ->(dbsetorder(1),msseek(cChaveEKJ))         
                  If EKJ->EKJ_MSBLQL == '1'
                     Help(" ",1,"CP400OPBLQ") //"Registro do operador estrangeiro encontra-se bloqueado. Para utiliz�-lo efetue o desbloqueio do registro no Cadastro do Op. Estrangeiro"##"Aten��o"
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
            If lRet
               If lMultiFil
                  //           oModelEKB:getvalue("EKB_FILORI",oModelEKB:getline())+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline()) //MFR 11/02/2022 OSSME-6595               
                  //neste caso o cFil j� foi preenchdo acima
                  cChaveSA2 := cFil+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline()) 
               Else
                  cChaveSA2 := xFilial("SA2")+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline())
               EndIf
               cRet:='' ////MFR 11/02/2022 OSSME-6595
               If SA2->(dbsetorder(1),msseek(cChaveSA2))
                  cRet := SA2->A2_PAIS
               EndIf 

               If Empty(cRet)
                  EasyHelp(STR0087,STR0002,STR0088)  //Problema: "O c�digo do Pa�s de origem n�o foi preenchido no Cadastro de Fornecedores/Fabr." Solu��o: "Acesse o Cadastro do Fabricantes/Forn. e preencha o c�digo do Pa�s de origem do Fabricante na aba 'Cadastrais' "
                  lRet := .F.	   
               EndIf
            EndIf
         EndIf                         
      Case cCampo == "EK9_UNIEST" 
         lRet := Vazio() .OR. ExistCpo("SAH",oModelEK9:GetValue("EK9_UNIEST"))
         If !lRet
            EasyHelp(StrTran(STR0022, "#####", oModelEK9:GetValue("EK9_UNIEST")),STR0002,STR0105) //"Unidade de Medida: ##### da NCM n�o encontrada no cadastro de unidade de medida"##"Aten��o" Solu��o: "Revise o cadastro da NCM ou cadastre a unidade de medida"
         Endif
      Case cCampo == "EK9_NCM"
         lRet := (lRet .or. Vazio()) .and. ExistCpo("SYD",oModelEK9:GetValue("EK9_NCM")) 
         // mesmo retornando .F.(quando responde Nao) no controle do campo EKA_PRDREF, o sistema por falha do componente quando
         //entra aqui de novo est� com o valor do campo M->EK9_NCM como se tivesse respondido Sim
         if !Empty(cNcmAux) 
            M->EK9_NCM := cNcmAux
            oModelEK9:LoadValue("EK9_NCM",cNcmAux)
            cNcmAux:=""
         EndIf
         If lREt .and. oModelEKC:Length() > 0 .and. oModelEK9:GetValue("EK9_NCM") <> cNcm
            If !Empty(oModelEKC:GetValue("EKC_CODATR"))
               If IsMemVar("lCP400Auto") .And. !lCP400Auto  //se n�o for execauto exibe a pergunta se n�o segue como sim 
                  lRet := MsgNoYes(STR0032,STR0002) // "Confirma altera��o do NCM, se confirmar todas as informa��es sobre os atributos ser�o perdidas" ### "Aten��o"
               EndIf
               If lRet
                  CP400Ncm(oModelEK9,oModelEKA)
               EndIf
            EndIf
         EndIf
      Case cCampo == "EK9_IDMANU"
         If !Empty(oModelEK9:getvalue("EK9_IDPORT"))
            //EasyHelp(STR0079,STR0002) //"N�o � poss�vel digitar ID Manual j� que o ID Portal j� est� preenchido"
            Help(" ",1,"CP400IDMAN")   //"N�o � poss�vel digitar ID Manual j� que o ID Portal j� est� preenchido"         
            lRet := .F.
         EndIf
      Case cCampo == "EK9_VSMANU"
         If(lPosicEKD .And. (EKD->EKD_STATUS == '1' .Or. EKD->EKD_STATUS == '3'))
            If M->EK9_VSMANU < EKD->EKD_VERSAO
               EasyHelp(StrTran(STR0038, "###", EKD->EKD_VERSAO),STR0002) //"A vers�o informada manualmente � menor que a vers�o ### Integrada ou Cancelada"###"Aten��o"
               lRet := .F.
            EndIf
         EndIf
      Case cCampo == "EK9_DSCCOM"
         If len(oModelEK9:getvalue("EK9_DSCCOM")) > 3700
            EasyHelp(STR0096,STR0002) //"O campo de descri��o complementar n�o pode ter mais de 3700 caracteres!"  "###"Aten��o"
            lRet := .F.
         EndIf
      Case cCampo == "EKB_CODFAB"        
         Do Case
           Case Empty(oModelEK9:GetValue("EK9_CNPJ"))  // MFR 11/02/2022 OSSME-6598
                 lRet:=.F.
                 EasyHelp(STR0104,STR0002,STR0103) //Campo CNPJ n�o informado. Informe primeiro o campo CNPJ Raiz
            Case !Vazio() .And. !ExistCpo("SA2",oModelEKB:getvalue("EKB_CODFAB"))
                 lRet:=.F.
                 EasyHelp(STR0097,STR0002,STR0098) //Problema: "Fabricante informado n�o cadastrado!"  "###"Aten��o"  Solu��o: "Consulte a lista de fabricantes cadastrados no sistema pressionando F3 sobre o campo ou acesse o cadastro de fabricantes e realize o cadastro do fabricante informado."  
         EndCase        
      Case cCampo == "EKB_PAIS"  
         lRet := Vazio() .or. ExistCpo("SYA",oModelEKB:getvalue("EKB_PAIS"))
         If !lRet
            Help(" ",1,"CP400PAIS") //Problema: N�o existe o Cod. de Pais digitado Solu��o: Consulte a lista de c�digo de pa�ses e digite um cod. de Pais v�lido.
         EndIf
   EndCase	
   lRetAux := lRet

Return lRet

/*
Fun��o     : CP400PsFil()
Objetivo   : Pesquisa filial para o produto digitado - quando nao via F3(consulta padr�o/especifica)
Par�metros : cCampo - Produto a ser pesquisado
			 cTable - Tabela EKA - uso escpecifico para posicionar no produto SB1 para a filial encontrada
Retorno    : lRet - retorna se achou filial para o produto digitado
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400PsFil(cPesq,cFil,cTable)
   Local aFil := {}
   Local lRet := .F.

   If(cFil == Nil, aFil := FWAllFilial(), aAdd(aFil,cFil))

   If cTable == "SB1"
      dbSelectArea("SB1")
      SB1->(DbSetOrder(1)) //Filial + Produto
      lRet := aScan(aFil,{|X| MsSeek(X+cPesq)}) > 0
   Else
      dbSelectArea("SA2")
      SA2->(DbSetOrder(1)) //Filial + Cod + Loja
      lRet := aScan(aFil,{|X| MsSeek(X+cPesq)}) > 0
   EndIf

Return lRet

/*
Fun��o     : CP400IniBrw()
Objetivo   : Inicializa Browse - conteudo exibido no browse para campo passado por parametro
Par�metros : cCampo - Campo a a ser inicializado no browse
Retorno    : cRet - Conteudo a ser inicializado no browse
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400IniBrw(cCampo)
   Local cRet	:= ""
   Local aArea	:= GetArea()

   If  cCampo == "EK9_DESC_I"
      If lMultiFil
         cRet := POSICIONE("SB1",1,EK9->EK9_FILORI+EK9->EK9_PRDREF,"B1_DESC")
      Else
         cRet := POSICIONE("SB1",1,xFILIAL("SB1")+EK9->EK9_PRDREF,"B1_DESC")
      EndIf
   EndIf

   RestArea(aArea)

Return cRet

/*
Fun��o     : CP400Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Par�metros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :  
*/
Function CP400Gatil(cCampo)
   Local aArea		   := GetArea()
   Local oModel	   := FWModelActive()
   Local oGridEKB    := oModel:GetModel("EKBDETAIL")
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local cRet        := ""
   Local cChaveEKJ   := ""
   Local cChaveEKJ2  := ""
   Local cChaveSA2   := ""
   Local lAchouSA2   := .F.

   Do Case
      Case cCampo == "EKB_NOME"
         If !Empty(SA2->A2_NOME)
            cConteu := SA2->A2_NOME             
            FwFldPut("EKB_NOME",AvKey(cConteu,"EKB_NOME"))
         EndIf   
      Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"
         If lMultiFil
            cChaveSA2 := oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         Else
            cChaveSA2 := oGridEKB:getvalue("EKB_FILIAL",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         EndIf
         if SA2->(dbsetorder(1),msseek(cChaveSA2))
            cChaveEKJ := SA2->A2_FILIAL+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA
            cChaveEKJ2 := SA2->A2_FILIAL+AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R")+SA2->A2_COD+SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            if EKJ->(msseek(cChaveEKJ)) .Or. EKJ->(msseek(cChaveEKJ2))
               if cCampo == "EKB_OENOME"
                  cRet := EKJ->EKJ_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
               elseif cCampo == "EKB_OESTAT"
                  cRet := EKJ->EKJ_STATUS
               elseif cCampo == "EKB_OPERFB"
                  cRet := EKJ->EKJ_TIN 
               endif
            elseif SA2->(dbsetorder(1),msseek(cChaveSA2)) //ta desposicionando na SA2 ao fazer o Seek da EKJ
               if cCampo == "EKB_OENOME"
                  cRet := SA2->A2_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
               elseif cCampo == "EKB_OESTAT"
                  cRet := "2"
               endif
            endif
         endif
      Case cCampo $ "EKB_LOJA"
         If lMultiFil
            cFil := Nil
            If !Empty(oGridEKB:GetValue("EKB_CODFAB"))           
               lAchouSA2 := IsInCallStack("F3GET") .Or. CP400PsFil(oGridEKB:GetValue("EKB_CODFAB"),cFil,"SA2")                      
            EndIf   
         ElseIf !Empty(oGridEKB:GetValue("EKB_CODFAB"))  
            lAchouSA2 := IsInCallStack("F3GET") .Or. CP400PsFil(oGridEKB:GetValue("EKB_CODFAB"),xFilial("SA2"),"SA2")             
         EndiF
         If lAchouSA2
            cRet := SA2->A2_LOJA
         EndIf         
      Case cCampo == "EKB_PAIS"   
         If lMultiFil
            cChaveSA2 := oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         Else
            cChaveSA2 := xFilial("SA2")+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         EndIf
         If SA2->(dbsetorder(1),msseek(cChaveSA2))
            cRet := SA2->A2_PAIS
         EndIf 
      Case cCampo == "EKB_PAISDS"   
            If !Empty(oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()))
            cRet := POSICIONE("SYA",1,xFilial("SYA")+oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()),"YA_DESCR")
         EndIf       
   EndCase

   RestArea(aArea)

Return cRet

/*
Fun��o     : CP400Condc(cCampo)
Objetivo   : Regras de condicao para gatilho ser executo para diversos campos
Par�metros : cCampo - campo cujo condicao de execu��o do gatilho deve ser verificada
Retorno    : lRet
Autor      : Ramon Prado
Data       : Jan/2020
Revis�o    :
*/
Function CP400Condc(cCampo)
   Local lRet := .F.

   Do Case
      Case cCampo == "EKA_PRDREF"   
         lRet := LMULTIFIL .And. !EMPTY(FWFLDGET("EKA_PRDREF"))
      Case cCampo == "EKB_LOJA"
         lRet := lMultiFil .And. !EMPTY(FWFLDGET("EKB_LOJA"))
   EndCase

Return lRet

/*
Fun��o     : CP400ArPrd()
Objetivo   : Carrega Array de Produtos digitados no grid Rela��o de Produtos
Par�metros : Nil
Retorno    : Array de Produtos
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400ArPrd(oModelPrd)
   Local aArea       := GetArea()
   Local aArrayProd  := {}
   Local nI          := 1

   If oModelPrd:Length() > 0
      For nI := 1 to oModelPrd:Length()		
         oModelPrd:GoLine(nI)
         if !Empty(oModelPrd:GetValue("EKA_PRDREF"))
               aAdd(aArrayProd, {oModelPrd:GetValue("EKA_PRDREF"),if(lMultiFil,oModelPrd:GetValue("EKA_FILORI"),xFilial("EKA"))})
         EndIf
      Next nI
   EndIf

   RestArea(aArea)

Return aArrayProd

/*
Fun��o     : CP400VlSA5()
Objetivo   : Pesquisa Amarracao Produto XFornecedor Ou Produto X Fabricante
Par�metros : Nil
Retorno    : lRet - Encontrou Amarracao de produto x Fornecedor Ou Produto X Fabricante
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Function CP400VlSA5(cFabricant, cLoja, cProd, cFilOri)
   Local aArea		   := GetArea()
   Local lRet		   := .F.
   Local cFilSA5     := ""

   Default cFilOri   := ""

   iif(!Empty(cFilOri), cFilSA5 := cFilOri, cFilSA5 := xFilial("SA5") )

   SA5->(DbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
               
   If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(cProd, AVSX3("A5_PRODUTO",3)) + PADR(cFabricant, AVSX3("A5_FORNECE",3)) + PADR(cLoja, AVSX3("A5_LOJA",3)) ))
      lRet := .T.
   Else
      SA5->(DbSetOrder(4)) //A5_FILIAL+A5_FABR+A5_FALOJA+A5_PRODUTO
      If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(cFabricant, AVSX3("A5_FORNECE",3)) + PADR(cLoja, AVSX3("A5_LOJA",3)) + PADR(cProd, AVSX3("A5_PRODUTO",3)) ))
         lRet := .T.
      EndIf
   EndIF

   RestArea(aArea)

Return lRet

/*
Fun��o     : CP400CarFb()
Objetivo   : Pesquisa Amarracao Produto XFornecedor Ou Produto X Fabricante e carrega a lista no grid de fabricantes conforme produto digitado
Par�metros : Nil
Retorno    : Nil
Autor      : Ramon Prado
Data       : Abr/2021
Revis�o    :
*/
Function CP400CarFb()
   Local aArea := getArea()
   Local oModel      := FWModelActive()
   Local oModelEK9	:= oModel:GetModel("EK9MASTER")
   Local oModelEKB	:= oModel:GetModel("EKBDETAIL")
   Local cFilSA5     := ""
   Local lMsgYesNo   := .T.
   Local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   Local cPais,cBlq
   
   If !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. (cPrdRefEK9 <> oModelEK9:GetValue("EK9_PRDREF")) .And. oModel:GetOperation() != EXCLUIR 
      
      cPrdRefEK9 := oModelEK9:GetValue("EK9_PRDREF")
      /* //MFR 14/02/2022 OSSME-6592 Retirado para n�o apagar os fabricantes j� existentes
      If oModel:GetOperation() == INCLUIR
         oModelEKB:DelAllline()     
         oModelEKB:ClearData(.T.,.T.)     
      EndIf 
      */
      
      //If(!Empty(oModelEKA:GetValue("EKA_FILORI",getLine())), cFilSA5 := oModelEKA:GetValue("EKA_FILORI",getLine()), cFilSA5 := xFilial("SA5") )
      cFilSA5 := xFilial("SA5")
      SA5->(DbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
   
      //Cadastro de Produto x Fornecedor/Fabricante             
      If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(oModelEK9:GetValue("EK9_PRDREF"), AVSX3("A5_PRODUTO",3))))
         If !lCP400Auto //exibe a pergunta apenas para rotinas n�o automaticas, rotina automatica a variavel lMsgYesNo � "Sim"   
            lMsgYesNo := MsgYesNo(STR0073,STR0021) //"Deseja carregar a lista de Fabricantes/Fornecedores associados ao Produto? Ser�o considerados apenas os cadastros que possuirem o pa�s informado" 
         EndIf
         If lMsgYesno 
            While SA5->(!EOF()) .And. SA5->(A5_FILIAL+A5_PRODUTO) == cFilSA5+oModelEK9:GetValue("EK9_PRDREF")            
               If !oModelEKB:SeekLine({{"EKB_CODFAB", SA5->A5_FORNECE},{"EKB_LOJA", SA5->A5_LOJA}})
                  cPais := Posicione("SA2",1,xFilial("SA2")+SA5->A5_FORNECE+SA5->A5_LOJA,"A2_PAIS") //MFR 14/02/2022 OSSME-6592
                  cBlq  :=  Posicione("EKJ",1,xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA,"EKJ->EKJ_MSBLQL") // MFR 11/02/2022 OSSME-6598
                  If !Empty(Cpais) .And. cBlq != "1"
                     if !(oModelEKB:length()==1 .AND. Empty(oModelEKB:GetValue("EKB_CODFAB"))) 
                        ForceAddLine(oModelEKB, .F./*N�o permite bloquear grid para nova inser��o de linhas*/) 
                     EndIf 
                     oModelEKB:SetValue("EKB_CODFAB", SA5->A5_FORNECE)
                     oModelEKB:SetValue("EKB_LOJA", SA5->A5_LOJA) 
                  EndIf                 
               Endif                                                 
               SA5->(DbSkip())      
            EndDo  
            oModelEKB:GoLine(1) //posiciona na linha 1
         EndIf   
      EndIf
            
   Endif

   RestArea(aArea)
Return cRet

/*
Fun��o     : CP400ATRIB() Gatilho EK9_NCM
Objetivo   : Monta o grid com os atributos de acordo como ncm(gatilho no ncm da EK9)
             
Par�metros : Nenhum
Retorno    : lRet
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400ATRIB(lEvento)

   Local aDominio    := {}
   Local oModel      := FWModelActive()
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   Local lFirst      := .t.
   Default lEvento := .F.

   if !Empty(oModelEK9:GetValue("EK9_NCM")) .And. (cNcm <> oModelEK9:GetValue("EK9_NCM") .Or. cModalEK9 <> oModelEK9:GetValue("EK9_MODALI")) .And. oModel:GetOperation() != EXCLUIR
      cNcm := oModelEK9:GetValue("EK9_NCM") 
      cModalEK9 := oModelEK9:GetValue("EK9_MODALI")
      lFirst := IIF(lEvento,.F.,lFirst)
      If oModel:GetOperation() == INCLUIR
         oModelEKC:DelAllline()     
         oModelEKC:ClearData(.T.,.T.)     
         lFirst := .T.
      EndIf

      DbSelectArea("EKG")
      //EKG->(DBSETORDER(2))
      If EKG->(DBSEEK(xFilial("EKG")+oModelEK9:GetValue("EK9_NCM")))
         aAtrib := {}
         While EKG->(!Eof()) .AND. EKG->EKG_NCM == oModelEK9:GetValue("EK9_NCM")      
            If !oModelEKC:SeekLine({{"EKC_COD_I", EK9_COD_I} ,{"EKC_CODATR", EKG_COD_I  }})
               if CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG) != "EXPIRADO" .And. (M->EK9_MODALI == EKG->EKG_MODALI .OR. M->EK9_MODALI == "3" .OR. EKG->EKG_MODALI == "3" .Or. Empty(EKG->EKG_MODALI)) 
                  if lFirst .OR. (oModelEKC:length()==1 .AND. empty(oModelEKC:getVAlue("EKC_CODATR")) )
                     lFirst := .f.
                  Else
                     ForceAddLine(oModelEKC)
                  EndIf
                  oModelEKC:LoadValue("EKC_CODATR",EKG->EKG_COD_I)
                  oModelEKC:LoadValue("EKC_STATUS",CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG))
                  oModelEKC:LoadValue("EKC_NOME",(if(EKG->EKG_OBRIGA == "1","* ","")) + AllTrim(EKG->EKG_NOME))
                  oModelEKC:LoadValue("EKC_VALOR","")
               EndIf  
            Else
               EKC->(dbSetOrder(1))
               If EKC->(dbSeek(xFilial("EKC") + M->EK9_COD_I + EKG->EKG_COD_I))
                  cTela := EKC->EKC_VALOR
                  if AllTrim(EKG->EKG_FORMA) == "BOOLEANO"
                     cTela := if(cTela=="1","SIM",if(cTela=="2","NAO",""))
                  ElseIf AllTrim(EKG->EKG_FORMA) == "LISTA_ESTATICA"
                     IF EKH->(DBSEEK(xFilial("EKH")+oModelEK9:GetValue("EK9_NCM")+EKC->EKC_CODATR+cTela))
                        cTela := ALLTRIM(EKH->EKH_CODDOM)+"-"+EKH->EKH_DESCRE
                     EndIf
                  EndIf
                  oModelEKC:LoadValue("EKC_VLEXIB",SubSTR(cTela,1,100))
               EndIf
            EndIf
            aDominio := {}
            iF EKH->(DBSEEK(xFilial("EKH")+EKG->EKG_NCM+EKG->EKG_COD_I)) // Tudisco EKH->(DBSEEK(xFilial("EKH")+EKG->EKG_COD_I))
               While EKH->(!Eof()) .AND. EKH->EKH_NCM == EKG->EKG_NCM .AND. EKH->EKH_COD_I == EKG_COD_I 
                  AADD(aDominio,{EKH->EKH_COD_I,EKH->EKH_CODDOM,EKH->EKH_DESCRE,""})
                  EKH->(DbSkip())
               EndDo
            EndIf
            AADD(aAtrib,{EKG->EKG_COD_I,EKG->EKG_NOME,EKG->EKG_FORMA,EKG->EKG_OBRIGA,EKG->EKG_TAMAXI,EKG->EKG_DECATR,EKG->(RECNO()),aDominio})
            EKG->(DbSkip())
         EndDo
         oModelEKC:GoLine(1) 
      EndIf
   EndIf

return .T.

/*
Fun��o     : ForceAddLine()
Objetivo   : For�a adi��o de linha na tela de grid
Par�metros : oModelGrid
Retorno    : .T.
Autor      : Maur�cio Frison
Data       : Mar/2020
*/
Static Function ForceAddLine(oModelGrid, lControlLn)
   Local oModel   := FWModelActive()
   Local lDel     := .F.

   Default lControlLn := .T.

      nOperation := oModel:GetOperation()
      If lControlLn
         oModelGrid:SetNoInsertLine(.F.)
      EndIf
      if nOperation == 1
         oModel:nOperation := 3
      EndIf

      If oModelGrid:Length() >= oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If !oModelGrid:IsDeleted()
            oModelGrid:DeleteLine()
            lDel := .T.
         EndIf
         oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If lDel
            oModelGrid:UnDeleteLine()
         EndIf
         oModelGrid:GoLine(oModelGrid:Length())
      EndIf

      If lControlLn
         oModelGrid:SetNoInsertLine(.T.)
         //oModelGrid:SetNoDeleteLine(.T.)
      EndIf   
      oModel:nOperation := nOperation

Return .T.

/*
Fun��o     : CP400Status()
Objetivo   : Gera o status conforme data da vig�ncia e data base            
Par�metros : dDataVigencia
Retorno    : Status
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400Status(dIniVig,dFimVig)
   Local cReturn := ""

   If !Empty(dIniVig) .And. dIniVig > dDataBase
      cReturn := "FUTURO"
   ElseIf !Empty(dFimVig) .And. dFimVig < dDataBase 
      cReturn := "EXPIRADO"
   Else
      cReturn := "VIGENTE"
   Endif

Return cReturn
/*
Fun��o     : CP400TELA() Gatilho campo EKC_CODATR
Objetivo   : Abrir uma tela diferente para cada tipo de dado de acordo com as tabelas EKG e EKH
Par�metros : cCodAtr c�digo do atributo
Retorno    : cTela - Retorna a informa��o selecionada pelo usu�rio
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400TELA()
   Local oModel    := FWModelActive()
   Local oModelEKC := oModel:GetModel("EKCDETAIL")
   Local oView     := FWViewActive()
   Local cForma 
   Local lRetorno

   Private cTela := ""

   if oModelEkc:getOperation() == 1
      lRetorno := .F.
   Else
      cAtr := oModelEKC:GetValue("EKC_CODATR")
      cForma := CP400Campo(cAtr,3)
      CP400CapaAtr(cForma,cAtr)
      oview:Refresh("EKCDETAIL")
      lRetorno := .T.
   EndIf

Return lREtorno

/*
Fun��o     : CP400Campo()
Objetivo   : Pegar a forma de preenchimento do atributo
Par�metros : cAtributo o c�digo do atributo, nCampo posi��o qeu define qual campo ser� retornado
Retorno    : valor - Retorna o campo de preenchimento do atributo
Autor      : Maur�cio Frison
Data       : Mar/2020
nCampo             1              2             3              4               5               6          7               8
            : EKG->EKG_COD_I,EKG->EKG_NOME,EKG->EKG_FORMA,EKG->EKG_OBRIGA,EKG->EKG_TAMAXI,EKG->EKG_DECATR,EKG->(RECNO()),aDominio}
Revis�o    :
*/
Function CP400Campo(cAtributo,nCampo)
   Local valor
   Local nPos := ascan(aAtrib, {|x| AllTrim(x[1]) == AllTrim(cAtributo)})

   if nPos > 0
      if valtype(aAtrib[nPos][nCampo]) == "C"
         valor := AllTrim(aAtrib[nPos][nCampo])
      Else
         valor := aAtrib[nPos][nCampo]
      EndIf   
   EndIf

Return valor

/*
Fun��o     : CP400CapaAtr()
Objetivo   : Exibir a tela de capa do atributo
Par�metros : cForma - � a forma de preenchimento que veio da tabela ekg
Retorno    : 
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400CapaAtr(cForma,cAtr)
   Local oModel      := FWModelActive()
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   Local cPict       := ""
   Local cObrig      := ""
   Local cValor      := ""
   Local cTela       := ""
   Local nTam        := 0
   Local nDec        := 0
   Local nValor      := 0
   Local aLista      := {}
   Local npos        := 1
   Local bOk		   := {|| lRet:= .T., CP400GravaAtr(oModelEKC,cTela,cValor) , oDlg:End()}
   Local bCancel     := {|| lRet:= .F., CP400ViewAtr()  , oDlg:End()}
   Local aItems      := {'1-SIM','2-NAO'}
   Local lHtml       := .T.
   Local oPanelEnch
   Local oPanelAtr
   Local cTituloAtributos := "Edi��o de Atributos"
   Local cTextHtml   := ""
   Local cNotCampos  := ""
   Local aCposExib   := {}
   Local aSeek       := {}
   Local cCampo
   
   Private oBrowse
   Private aRotina  := menudef()
   Private cLabelGrid := ""
   Private cTelaView  := "" 

   nLinIni := DLG_LIN_INI+100
   nColIni := DLG_COL_INI+100
   nLinFim := DLG_LIN_FIM
   nColFim := DLG_COL_FIM

   If !Empty(cAtr)
      EKG->(DBGOTO(CP400Campo(cAtr,7))) 
      RegToMemory("EKG", .F.)
      
      cNotCampos += "EKG_CODOBJ/EKG_FORMA/EKG_TAMAXI/EKG_DECATR/EKG_BRIDAT" //Campos que n�o ser�o exibidos na tela da edi��o de atributos - OSSME-5342 - RNLP
      
      //Adicionando os campos a serem apresentados na Enchoice 
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EKG"))
      While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EKG"
         If !(AllTrim(SX3->X3_CAMPO) $ cNotCampos) .And. X3Uso(SX3->X3_USADO)
            If SX3->X3_CAMPO == "3"
               Aadd(aCampos,SX3->X3_CAMPO)
            EndIf
            Aadd(aCposExib,SX3->X3_CAMPO)
         EndIf 
      SX3->(DbSkip())
      EndDo

      DEFINE MSDIALOG oDlg TITLE cTituloAtributos FROM nLinIni,nColIni TO nLinFim,nColFim OF oMainWnd PIXEL

         // Panel para a enchoice
         nWidth            := PosDlg(oDlg)[4]
         nHeight           := round(PosDlg(oDlg)[3] * 0.6,0)
         oPanelEnch        := TPanel():New(0,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight)
         oPanelEnch:Align  := CONTROL_ALIGN_TOP

         // enchoice
         oEnCh             := MsMGet():New("EKG", ,2, , , , aCposExib,PosDlg(oPanelEnch),{},,,,,oPanelEnch,.T.)
         oEnch:oBox:Align  := CONTROL_ALIGN_TOP //CONTROL_ALIGN_ALLCLIENT
         cObrig            := CP400Campo(cAtr,4)
         cTela             := oModelEKC:GetValue("EKC_VALOR")
         cValor            := oModelEKC:GetValue("EKC_VALOR")
         cTelaView         := oModelEKC:GetValue("EKC_VLEXIB")

         // Panel para a Say
         nLinIni           := round(PosDlg(oDlg)[3] * 0.6,0) - noround(PosDlg(oDlg)[3] * 0.05,0)
         nHeight           := round(PosDlg(oDlg)[3] * 0.06,0)
         oPanelSay         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,/* CLR_BLUE */,nWidth,nHeight)
         // oPanelSay:Align   := CONTROL_ALIGN_ALLCLIENT

         // TSay permitindo texto no formato HMTL
         nCol              := 5
         oSay              := TSay():New(01,nCol,{|| '' },oPanelSay,,,,,,.T.,CLR_BLACK,/* CLR_YELLOW */,nWidth,nHeight,,,,,,lHtml)
         oSay:Align        := CONTROL_ALIGN_ALLCLIENT
         oSay:SetTextAlign( 2, 2 )

         // Panel para o atributo
         nLinIni           += nHeight + 1
         nHeight           := PosDlg(oDlg)[3] * 0.4
         oPanelAtr         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight,.T.,.T.)
         oPanelAtr:Align   := CONTROL_ALIGN_BOTTOM
         nRow              := 30

         // Atributo a ser inclu�do
         DO CASE

            CASE cForma == "LISTA_ESTATICA"

               cTextHtml := '<font size="6" color="black">Selecione na lista o valor do atributo</font><br/>'

               bOk := {|| If(Len(aLista) > 0, nAt := getPosAtrib(oBrowse), ), If(nAt > 0,cValor := aLista[nAt][2], ), If(nAt > 0, cTela := AllTrim(cValor)+"-"+aLista[nAt][3], ), If(nAt > 0, CP400GravaAtr(oModelEKC,cTela,cValor), ) , oDlg:End() }
               aLista := CP400Campo(oModelEKC:GetValue("EKC_CODATR"),8)
               nPos := AScan(aLista, {|x| x[2] == cTela})
               bDuploClick := {|oBrowse| duploClickAtributo(oBrowse) }

               // Define o Browse
               cCampo := CP400Campo(oModelEKC:GetValue("EKC_CODATR"),2)
               AAdd(aSeek, {cCampo, {{"", "C", LEN(aLista[1][2]), 0, cCampo,,cCampo}},1,.T.})

               oBrowse := FWBrowse():New(oPanelAtr)
               oBrowse:SetProfileID("CP400FwBrw")
               oBrowse:SetClrAlterRow(15000804)
               oBrowse:setDataArray()
               oBrowse:setArray( aLista )
               oBrowse:SetSeek(,aSeek)
               //oBrowse:disableConfig() //se deixar esta linha n�o funciona a automa��o e teve que incluir o SetSeek tamb�m para funcionar
               oBrowse:disableReport()

               oBrowse:AddMarkColumns({|oBrowse| iif( marcaAtributo(oBrowse) ,'LBOK','LBNO') },;
                                                bDuploClick,;
                                                {|oBrowse| headerClickAtributo(oBrowse) })

               // Adiciona as colunas do Browse 
               oColumn := FWBrwColumn():New()
               oColumn:SetData(&('{ || aLista[oBrowse:At()][2] }'))
               oColumn:ReadVar('aLista[oBrowse:At()][2]')
               oColumn:SetTitle(AvSX3('EKH_COD_I')[5])
               oColumn:SetSize(AvSX3('EKH_COD_I')[3])
               oColumn:SetDoubleClick(bDuploClick)

               oBrowse:SetColumns({oColumn})

               oColumn := FWBrwColumn():New()
               oColumn:SetData(&('{ || aLista[oBrowse:At()][3] }'))
               oColumn:ReadVar('aLista[oBrowse:At()][3]')
               oColumn:SetTitle(CP400Campo(oModelEKC:GetValue("EKC_CODATR"),2))
               oColumn:SetSize(100)
               oColumn:SetDoubleClick(bDuploClick)

               oBrowse:SetColumns({oColumn})

               oBrowse:Activate()

            CASE cForma == "TEXTO"

               cLabelGrid  := lower(CP400Campo(cAtr,2)) 
               cTextHtml   := '<font size="6" color="black">'+cLabelGrid+'</font><br/>'
               nTam        := CP400Campo(cAtr,5)
               bValid      := {|u| CP400VlTexto(u,@cValor,nTam,@cTela)  }
               cLabelAux   := 'Caracteres' + " (" + AllTrim(str(nTam)) + ")"
               nRow        := 5
               nWidth      := PosDlg(oPanelAtr)[4] - 6
               nHeight     := PosDlg(oPanelAtr)[3]
               bSetGet     := {|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}
               
               oMulti      := TSimpleEditor():New(nRow,nCol,oPanelAtr,nWidth,nHeight,,.F.,bSetGet,,.T.,,bValid,cLabelAux,1)
               oMulti:bGetKey  := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam) }
               oMulti:bChanged := {|self,oDlg| CP400Changed(self,@cTela,oPanelAtr,nTam) }
               oMulti:load(cTela)
               oMulti:SetMaxTextLength( nTam )
               // oMulti := TMultiget():New(nRow,nCol,{|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}, ;
               // oPanelAtr,nWidth,nHeight,,,,,,.T.,,,bValid,,,,bValid,,,.F.,.T. ,cLabelAux,1 )
               // oMulti:bGetKey := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam) }
               
            CASE cForma $ "NUMERO_REAL|NUMERO_INTEIRO"

               //tela com n�mero com picture correspondente
               cTitle      := lower(CP400Campo(cAtr,2))
               cTextHtml   := '<font size="6" color="black">'+cTitle+'</font><br/>'
               nTam        := CP400Campo(cAtr,5)
               nDec        := CP400Campo(cAtr,6)
               cPict       := CP400GeraPic(nTam,nDec)
               cTela       := StrTran(cTela,".","")
               cTela       := StrTran(cTela,",",".")
               nValor      := val(cTela)
               nWidth      := 80
               nHeight     := 20

               TGet():New(nRow,nCol, { | u | If( PCount() == 0, nValor, (nValor := u, cTela := alltrim(Transform(nValor,cPict)),cValor:=cTela) ) },oPanelAtr, ;
               nWidth,nHeight, cPict ,, 0, ,,.F.,,.T., ,.F., ,.F.,.F., ,.F.,.F. ,,"nValor",,,,.T.,.F., ,"",1 )
            
            CASE cForma == "BOOLEANO"
               
               // Tela combox sim ou nao
               cTitle      := lower(CP400Campo(cAtr,2))
               cTextHtml   := '<font size="6" color="black">'+cTitle+'</font><br/>'
               cCombo1     := if(cValor == "", aItems[2], if(cValor =="1", aItems[1], aItems[2]))
               cTela       := right(cCombo1,3)
               cValor      := left(cCombo1,1)
               nWidth      := 80
               nHeight     := 20

               oCombo1  := TComboBox():New(nRow,nCol,{ |u| if(PCount()>0, cCombo1:=u , cCombo1) },;
               aItems,nWidth,nHeight,oPanelAtr, , { || cTela:=right(cCombo1,3), cValor:=left(cCombo1,1) } ;
               , , , ,.T., , , , , , , , , "cCombo1" , "",1)
               
         EndCase
         oSay:SetText( cTextHtml )

      Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	CENTERED
   EndIf
      
Return 

/*/{Protheus.doc} getPosAtrib
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Function getPosAtrib(oBrowse)
   Local oData    := oBrowse:Data()
   Local nPos     := 0
   Local nC       := 0

   aEval(oData:aArray, {|x| nC++, iif( ! empty(x[4]) .and. x[4] == 'LBOK' , nPos := nC , ) })

Return nPos

/*/{Protheus.doc} marcaAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function marcaAtributo(oBrowse)
   Local lRet     := .F.
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   
   if len(oData:aArray) > 0
      if ! empty(oData:aArray[nPos][4]) .and. oData:aArray[nPos][4] == 'LBOK'
         lRet := .T.
      endif
   endif

Return lRet
/*/{Protheus.doc} duploClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function duploClickAtributo(oBrowse)
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   Local nCount   := 0

   aEval(oData:aArray, {|x| nCount++, x[4] := iif( nCount == nPos, 'LBOK', 'LBNO' ) })
   oBrowse:Refresh(.T.)

Return
/*/{Protheus.doc} headerClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function headerClickAtributo(oBrowse)
   Local oData    := oBrowse:Data()

   aEval(oData:aArray, {|x| x[4] := 'LBNO' })
   oBrowse:Refresh(.T.)

Return

/*
Fun��o   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o n�mero de caracters dispon�veis
Par�metros : cValor: o valor digitado, nTam: o tamanho m�ximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho m�ximo e .F. se passar deste tamanho
Autor      : Maur�cio Frison
Data       : abr/2020
Revis�o    :
*/
Function CP400Changed(objeto,cText,oDlg,nTam)
   
   if cText # nil
      objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len(cText))) + ")"
   endif

Return .T. 

/*
Fun��o   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o n�mero de caracters dispon�veis
Par�metros : cValor: o valor digitado, nTam: o tamanho m�ximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho m�ximo e .F. se passar deste tamanho
Autor      : Maur�cio Frison
Data       : abr/2020
Revis�o    :
*/
Function CP400GetKey(objeto,cText,nKey,oDlg,nTam)
   objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len(cText))) + ")"
Return .T. 

/*
Fun��o   : CP400VlTexto(oObjeto,nTam)
Objetivo   : trata o tamanho do campo e pergunta se quer truncar
Par�metros : objeto a trucar o texto, nTam: o tamanho m�ximo
Retorno    : lRet se truncou ou n�o o tamanho do objeto
Autor      : Maur�cio Frison
Data       : abr/2020
Revis�o    :
*/
Function CP400VlTexto(oObjeto,cValor,nTam,cTela)
   Local lRet := .T.

   if len(cValor) > nTam 
      lRet := MsgNoYes(STR0036) //Tamanho do campo excedido, as informa��es ser�o truncadas. Deseja prosseguir?
      if lRet
         cValor:=substring(cValor,1,nTam)
         cTela:=cValor
         oObjeto:load( cValor )
      EndIf
   EndIf

Return lRet 

/*
Fun��o     : CP400GravaAtr()
Objetivo   : Grava a informa��o no banco
Par�metros : cTela campo gerado na tela
Retorno    : 
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400GravaAtr(oModelEKC,cTela,cValor)

   oModelEKC:SetValue("EKC_VALOR",cValor)
   cTela := subString(cTela,1,100)
   oModelEKC:LoadValue("EKC_VLEXIB",cTela)

return .T.

/*
Fun��o     : CP400ViewAtr()
Objetivo   : Retorna a informa��o pra tela principal quando sai da tela do F3 sem Confirmar 
Par�metros : 
Retorno    : 
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400ViewAtr()
   cTela := cTelaView
return .T.

/*
Fun��o     : CP400GeraPic()
Objetivo   : Gera a picture de acordo com os par�meros
Par�metros : nTam tamanho total do campo inclusive com ponto decimal
             nDec n�mero de casas decimais
Retorno    : 
Autor      : Maur�cio Frison
Data       : Mar/2020
Revis�o    :
*/
Function CP400GeraPic(nTam,nDec)
   Local cPict := ""
   Local nI

   //define decimal
   For nI := 1 to nDec
      cPict := cPict+"9"
   Next
   if nDec <> 0
      cPict :=  "."+cPict
      nTam := nTAm - ndec -1 //-1 referente ao ponto decimal
   EndIf
   //defini parte inteira
   For nI := nTam to 1 step -1
      if Mod(nTam-nI,3) == 0 .And. (nTam-nI) > 0
            cPict := "9," + cpict
      Else 
            cPict := "9" + cpict 
      EndIf     
   Next
   cPict :=  "@E " + cPict

Return cPict

/*
Fun��o     : EKCLineValid()
Objetivo   : Funcao de Pre validacao do grid da EKC
Retorno    : T se quiser continuar e F se n�o quiser continuar
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revis�o    :
*/
Static Function EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.
 
   Do Case
      Case cAction == "DELETE" .And. !IsInCallStack("ForceAddLine") .And. !IsInCallStack("CP400POSVL") .And. !IsInCallStack("CP400ATRIB")
         If Alltrim(oGridEKC:GetValue("EKC_STATUS")) != "EXPIRADO"
            Help( ,, 'HELP',, STR0034, 1, 0) //"N�o � poss�vel excluir atributos com o status Vigente ou Futuro." 
            lRet := .F.
         EndIf
   
   EndCase

Return lRet


/*
Fun��o     : EKAPreValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se n�o quiser continuar
Autor      : Maur�cio Frison
Data       : Junho/2022
Revis�o    :
*/
Static Function EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.

   Do Case
      Case cAction == "UNDELETE" 
         lRet := CP400Valid('EKA_PRDREF',.T.)
   EndCase

Return lRet

/*
Fun��o     : EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
Objetivo   : Funcao para quando efetuado um duplo clik no item abrir em tela
Retorno    : Retorno l�gico
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revis�o    :
*/
Static Function EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
   Local lRet := .F.

   lRet := CP400TELA()

Return lRet
/*
Class      : CP400EV
Objetivo   : CLASSE PARA CRIA��O DE EVENTOS E VALIDA��ES NOS FORMUL�RIOS
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revis�o    :
*/
Class CP400EV FROM FWModelEvent
     
   Method New()
   Method Activate()
   Method VldActivate()

End Class
/*
Class      : M�todo New Class CP400EV 
Objetivo   : M�todo para cria��o do objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revis�o    :
*/
Method New() Class CP400EV
Return
/*
Class      : M�todo New Class CP400EV 
Objetivo   : M�todo para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revis�o    :
*/
Method Activate(oModel,lCopy) Class CP400EV
   cNCm  := "          "
   cModalEK9 := ""
   cPrdRefEK9 := ""   
   CP400ATRIB(.T.)
Return 

Method VldActivate(oModel) Class CP400EV
   local lRet := CP400ValAct(oModel)
Return lRet
/*
Fun��o     : EKALineValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se n�o quiser continuar
Autor      : Maur�cio Frison
Data       : Abr/2020
Revis�o    :
*/
Static Function EKALineValid(oModelEKA)
   Local lRet := .T.

   if IsInCallStack("CP400AtLn1") 
      lRet := lRetAux
   EndIf

Return lRet

/*
Fun��o     : EKBLnVlPos()
Objetivo   : Funcao de Pos validacao da linha do grid da EKB - Rela��o de Pa�ses de Origem e Fabricantes
Retorno    : T se validar  e F se n�o validar
Autor      : Ramon Prado
Data       : Maio/2021
Revis�o    :
*/
Static Function EKBLnVlPos(oModelEKB)
   Local lRet := .T.
   Local lEmpPais := .T.
   if oModelEKB:HasField("EKB_PAIS")
      lEmpPais :=  Empty(oModelEKB:GetValue("EKB_PAIS"))
   EndIf
   If Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS")) //informou o fabricante e o pa�s est� vazio
      Help(" ",1,"CP400FABRP") //"Veja que na linha: " ## "Problema: N�o foram informados fabricantes ou pa�ses de origem. Solu��o: Informe ao menos um pa�s de origem ou fabricante para prosseguir" 
      lRet := .F.
   EndIf

Return lRet


/*
Programa   : TemIntegEKD
Objetivo   : Verifica se para o Catalogo informado, existe registro Integrado ou Cancelado
Retorno    : .T. quando encontrar registro Integrado ou Cancelado; .F. n�o encontrar registro Integrado ou Cancelado
Autor      : Ramon Prado
Data/Hora  : Maio/2020
*/
Static Function TemIntegEKD(cCod_I)
   Local lRet := .F.
   Local cQuery

   cQuery := "SELECT EKD_COD_I FROM " + RetSQLName("EKD")
   cQuery += " WHERE EKD_FILIAL = '" + xFilial("EKD") + "' "
   cQuery += "   AND EKD_COD_I  = '" + cCod_I + "' "
   cQuery += "   AND (EKD_STATUS = '1' OR EKD_STATUS = '3') " //Registrado ou Cancelado
   cQuery += "   AND D_E_L_E_T_ = ' ' "

   If EasyQryCount(cQuery) != 0
      lRet := .T.
   EndIf

Return lRet


/*/{Protheus.doc} CP400IFbPO
   Fun��o que realiza a integra��o com o siscomex para cada fabricante/pa�s de origem 
   relacionado ao cat�logo de produtos integrado.
   @author Nilson C�sar
   @since 08/05/2021
   @version 1
/*/
Function CP400IFbPO(cPathAuth,cPathIAOE,oProcIntFb,lEnd,cErros,oEasyJS)
   Local nQtdInt     := 0
   Local cRet        := ""
   Local cAux        := ""
   Local cSucesso    := ""
   Local cCodigo     := ""
   Local ctxtJsonFB  := ""
   Local aFabrPaises := {}
   Local aJson       := {}
   Local aJsonErros  := {}
   Local lRet        := .T.
   //Local oEasyJS
   Local oJson
   Local cRetJson
   Local nFab
   Local nj,nInd
   Local cCpfCnpjR, cCodOEFB, cCpfCnpjFB, cConhFB, cCodProdF, cVincFB, cCodPaisF
   Local lEKFVincFB:=EKF->(FieldPos("EKF_VINCFB")) > 0 

   cChaveEKF := xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   If EKF->(DbSeek( cChaveEKF ))      
      Do While EKF->(!Eof()) .And. EKF->( EKF_FILIAL + EKF_COD_I + EKF_VERSAO ) ==  cChaveEKF
         If lEKFVincFB .And. !Empty(EKF->EKF_VINCFB) .And. !(EKF->EKF_VINCFB $ "3|4|5")  // NCF - 11/05/2021 - S� ser�o setados para integra��o fabricantes a vincular ou desvincular
            nQtdInt++
            aAdd( aFabrPaises, EKF->(Recno()) )
         EndIf
         EKF->(DbSkip())
      EndDo
   EndIf

   if !lCP400Auto
      oProcIntFb:SetRegua1(nQtdInt)
   endif
   for nFab := 1 to nQtdInt
      If lEnd	//houve cancelamento do processo
         lRet := .F.
         Exit
      EndIf
      EKF->(dbgoto(aFabrPaises[nFab]))

         if !lCP400Auto
            oProcIntFb:IncRegua1( STR0086 + EKF->EKF_CODFAB + "/" + EKF->EKF_LOJA /*  + "/" + EKF->EKF_PAIS*/ ) // "Integrando:"
            oProcIntFb:SetRegua2(1)
         endif

         cConhFB   := If( !Empty(EKF->EKF_CODFAB) , "true" , "false"    )
         cVincFB   := If(lEKFVincFB,If( EKF->EKF_VINCFB == "1" , "true" , "false" ),"false")
         cCpfCnpjR := EKD->EKD_CNPJ
         cCodProdF := EKF->EKF_COD_I
         cCodPaisF := EKF->EKF_PAIS // EKF->EKF_PAIS

         If !Empty(EKF->EKF_CODFAB)
            EKJ->(dbsetorder(1),msseek(  xFilial("EKJ") + EKD->EKD_CNPJ + EKF->EKF_CODFAB + EKF->EKF_LOJA  ))  // Posiciona no registro de Operador Estrangeiro do Fabricante
            if EKJ->EKJ_PAIS == "BR"
               SA2->(dbsetorder(1),msseek(xFilial("SA2") + EKF->EKF_CODFAB + EKF->EKF_LOJA))
               cCpfCnpjFB := SA2->A2_CGC 
               cCodOEFB   := ""
            else // se o pais origem for diferente de brasil manda o c�digo do operador estrangeiro
               cCodOEFB   := EKJ->EKJ_TIN
               cCpfCnpjFB := ""
            endif
            cCpfCnpjR := EKJ->EKJ_CNPJ_R
         Else
            cCodOEFB   := ""
            cCpfCnpjFB := ""
         EndIf

         ctxtJsonFB += If( nFab == 1,"[","")
         // Monta o texto do json para a integra��o
         ctxtJsonFB += '{' + ;
                        ' "seq": '                         + Alltrim(Str(nFab))  + ' ,' + ;
                        ' "cpfCnpjRaiz": "'                + cCpfCnpjR         + '",' + ;
                        ' "codigoOperadorEstrangeiro": "'  + cCodOEFB          + '",' + ;
                        ' "cpfCnpjFabricante": "'          + cCpfCnpjFB        + '",' + ;
                        ' "conhecido": "'                  + cConhFB           + '",' + ;
                        ' "codigoProduto": "'              + cCodProdF         + '",' + ;
                        ' "vincular": "'                   + cVincFB           + '",' + ;  //' "dataReferencia": "'             + 
                        ' "codigoPais": "'                 + cCodPaisF         + '"' + ;    //Campo Novo
                        '}'

         ctxtJsonFB += If( nFab < nQtdInt , "," , "]" )
         
      next nFab
      
      If nQtdInt > 0

         oEasyJS:runJSSync( CP400Auth( cPathAuth , cPathIFbPO , ctxtJsonFB ) ,{|x| cRet := x } , {|x| cErros := x } )

         // Pega o retorno e converte para json para extrair as informa��es
         if !Empty(cRet)
            cRet     := '{"items":'+cRet+'}'
            oJson    := JsonObject():New()
            cRetJson := oJson:FromJson(cRet)
            if valtype(cRetJson) == "U" 
               if valtype(oJson:GetJsonObject("items")) == "A"
                  aJson    := oJson:GetJsonObject("items")
                  For nInd := 1 To len(aJson)
                     cSucesso := aJson[nInd]:GetJsonText("sucesso")
                     cCodigo  := aJson[nInd]:GetJsonText("codigo")
                     cSequence:= aJson[nInd]:GetJsonText("seq")

                     if cSucesso == "false" .And. valtype(aJson[nInd]:GetJsonObject("erros")) == "A"
                        aJsonErros := aJson[1]:GetJsonObject("erros")
                        EKF->(dbgoto(aFabrPaises[ Val(cSequence)]))
                        cErros += "Fabricante: "+EKF->EKF_CODFAB+" | Loja: "+EKF->EKF_LOJA+" | Pa�s de Origem: "+EKF->EKF_PAIS+" | Erro: "   
                        for nj := 1 to len(aJsonErros)
                           cErros += aJsonErros[nj] + ENTER
                        next
                        if empty(cErros)
                           cErros += STR0060 //Arquivo de retorno inv�lido
                        endif                     
                     endif

                     //Atualiza a tabela de status da integra��o de fabricantes
                     if lEKFVincFB
                        EKF->(dbgoto(aFabrPaises[Val(cSequence)]))
                        cStatusInt := If(  Upper(cSucesso)=="TRUE" , If( EKF->EKF_VINCFB == "1" , "4"  , "5"    )    ,  EKF->EKF_VINCFB  )
                        If EKF->EKF_VINCFB <> cStatusInt
                           EKF->(RecLock("EKF",.F.))
                           EKF->EKF_VINCFB := cStatusInt
                           EKF->(MsUnlock())
                        EndIf
                     EndIf   
                     If !lCP400Auto
                        oProcIntFb:IncRegua2( If( Empty(cErros)  , STR0062 , STR0063 ) ) // "Integrado!"  // "Falha!"
                     EndIf

                  Next nInd
               else
                  cErros += STR0059 + ENTER // "Arquivo de retorno sem itens!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0071 + ENTER + alltrim(cRet) // "N�o foi poss�vel fazer o parse do JSON de retorno da integra��o."
            endif
         elseif empty(cErros)
            cErros += STR0061 + ENTER // "Integra��o sem nenhum retorno!"
         endif

         // caso d� tudo certo grava as informa��es e finaliza o registro
         if !( !empty(cRet) .and. !empty(cSucesso) .and. upper(cSucesso) == "TRUE" )
            lRet := .F.
            cAux += STR0090 + ENTER + cErros   // "Ocorreu um problema no retorno da integra��o de fabricantes: "
         endif

         cErros   := ""
         cRet     := ""
         cCodigo  := ""
         cSucesso := ""
      
         if !Empty(cAux)
            cErros := cAux
         endif
         
      EndIf

Return lRet

/*/{Protheus.doc} CP400ValAct
   Fun��o que � chamado pra saber se o Model ser� ativado e a tela do cat�logo ser� ou n�o aberta   
   @author Ramon Prado
   @since 18/05/2021
   @version 1
/*/
Function CP400ValAct(oModel)
   Local oModelEK9	:= oModel:GetModel("EK9MASTER")
   Local nOperation  := oModelEK9:GetOperation()
   Local lRet        := .T.
   Local cStatusEKD  := ""
   Local cCatEK9     := ""

   If nOperation == 4 //Altera��o   
      cCatEK9    := EK9->EK9_COD_I
      cStatusEKD := CP400StEKD(cCatEK9) //fun��o que retorna o Status da ultima integra��o/Historico do Cat�logo
      If cStatusEKD == '5' /*Registrado (pendente: fabricante/ pa�s)*/
         If MsgYesNo(STR0093) //"Existem pend�ncias de integra��o do Cat�logo de Produtos referente ao v�nculo de Operadores Estrangeiros. Deseja processar a integra��o pendente?" 
            lRet := CP400Integrar()
            If lRet
               cStatusEKD := CP400StEKD(cCatEK9) //fun��o que retorna o Status da ultima integra��o/Historico do Cat�logo
               If cStatusEKD == '5' /*Registrado (pendente: fabricante/ pa�s)*/ 
                  lRet := .F. //continua com Status Registrado (pendente: fabricante/ pa�s) -- Pend�ncia n�o resolvida de Integ. Fabricante
               EndIf
            EndIf
         Else
            lRet := .F.
         EndIf
      EndiF
   EndIf
   If !lRet   
      EasyHelp(STR0094,STR0002,STR0095) //Problema:"N�o foi poss�vel prosseguir com a altera��o do cat�logo de produtos!" ## Solu��o: "Para prosseguir com altera��o resolva a(s) pend�ncia(s) solicitando nova Integra��o do Cat�logo de Produtos"
   EndIf
Return lRet

/*/{Protheus.doc} CP400ValAct
   Fun��o que retorna o Status da ultima integra��o/Historico do Cat�logo
   @author Ramon Prado
   @since 18/05/2021
   @version 1
/*/
Function CP400StEKD(cCatEK9)
   Local cStatusEKD  := ""
   Local aArea       := GetArea()

   EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Vers�o
   If EKD->(AvSeekLAst( xFilial("EKD") + cCatEK9 ))
      cStatusEKD := EKD->EKD_STATUS
   EndIf

   RestArea(aArea)
Return cStatusEKD

Static Function AddColumns(aColumns, cAlias)
Local nInc
Local aStruct := (cAlias)->(DbStruct())
Local aBrowse := {}
Local cColumn, bBlock, cType, nSize, nDec, cTitle, cPicture, nAlign

	/* Array da coluna
	[n][01] T�tulo da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] M�scara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edi��o
	[n][09] Code-Block de valida��o da coluna ap�s a edi��o
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execu��o do duplo clique
	[n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
	[n][13] Code-Block de execu��o do clique no header
	[n][14] Indica se a coluna est� deletada
	[n][15] Indica se a coluna ser� exibida nos detalhes do Browse
	[n][16] Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
	*/
   For nInc := 1 To Len(aColumns)

      cColumn := Alltrim(aColumns[nInc])
      bBlock := &("{ ||" + cColumn + " }")
      cType := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][2]
      nSize := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][3]
      nDec := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][4]

      cTitle   := AvSX3(cColumn, AV_TITULO)
      cPicture := AvSX3(cColumn, AV_PICTURE)
      nAlign := If(cType<>"N", 1, 2)
      aAdd(aBrowse, {cTitle,bBlock,cType,cPicture,nAlign,nSize,nDec,.F.,{||.T.},.F.,{||.T.}, cColumn, {||.T.},.F.,.F.})
   Next

Return aBrowse


Static Function AllCpoIndex(cAlias,aColunas)
Local aInd
Local aAux
Local oAliasStru := FWFormStruct(1,cAlias)
Local nI
Local nY

Default aColunas := {}

aInd := oAliasStru:GetIndex()

For nI := 1 To Len(aInd)
   aAux := StrTokArr(aInd[nI][3],'+')
   For nY := 1 To Len(aAux)
      If aScan(aColunas,{|X| Alltrim(X) == Alltrim(aAux[nY])}) == 0
         aAdd(aColunas,Alltrim(aAux[nY]))
      EndIf
   Next
Next

Return aColunas
