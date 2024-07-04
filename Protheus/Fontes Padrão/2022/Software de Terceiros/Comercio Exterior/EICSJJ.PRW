#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJJ.CH"
#INCLUDE "AVERAGE.CH"

/*
Programa   : EICSJJ
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão
             definidas em um programa com o mesmo nome da função.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:09
Obs.       : Criado com gerador automático de fontes
Revisão    : Clayton Fernandes - 01/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/


Function EICSJJ()
   Local oBrowse

   //CRIAÇÃO DA MBROWSE
   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("SJJ") //Informando o Alias
   oBrowse:SetMenuDef("EICSJJ") //Nome do fonte do MenuDef
   oBrowse:SetDescription(STR0001)//Orgao Em.ato Legal
   oBrowse:Activate()

Return oBrowse
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:09
Revisão    : Clayton Fernandes - 01/04/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/

Static Function MenuDef()
   Local aRot     := {}
   Local aRotina  := {}

   //Adiciona os botões na MBROWSE
   ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"       OPERATION 1 ACCESS 0
   ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJJ" OPERATION 2 ACCESS 0
   ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJJ" OPERATION 3 ACCESS 0
   ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJJ" OPERATION 4 ACCESS 0
   ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJJ" OPERATION 5 ACCESS 0

   // a integração só será adicionada para quem tiver atualizado com os dados de formulário LPCO
   if avflags("FORM_LPCO")
      aRot := {{ STR0033 , "SJJIntgPU(.F.)" , 6, 0 },; //"Anuente Selecionado"
         { STR0034 , "SJJIntgPU(.T.)" , 6, 0 }} // "Todos"

      aAdd(aRotina, { STR0002 , aRot , 6, 0}) //"Integração de Formulários"
   endif

Return aRotina

//CRF
*-------------------------*
Static Function ModelDef()
   *-------------------------*
   Local oModel
   Local oStruSJJ  := FWFormStruct( 1, "SJJ") //Monta a estrutura da tabela SJO
   Local oStEKL

   aRelEKL := {{"EKL_FILIAL","xFilial('SJJ')"},;
      {"EKL_CODIGO","JJ_CODIGO"}}

   oModel := MPFormModel():New( 'EICSJJ', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

   oModel:AddFields( 'SJJMASTER', /*nOwner*/,oStruSJJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
   oModel:SetDescription(STR0001)    //Orgao Em.ato Legal
   oModel:SetPrimaryKey({'JJ_FILIAL','JJ_CODIGO'})

   if avflags("FORM_LPCO")
      oStEKL := FWFormStruct( 1, "EKL")
      oModel:AddGrid( 'EKLDETAIL' , 'SJJMASTER' , oStEKL  )
      oModel:GetModel("EKLDETAIL"):SetOptional( .T. )
      oModel:SetRelation("EKLDETAIL",aRelEKL, EKL->(IndexKey(1)))
      oModel:GetModel("EKLDETAIL"):SetDescription(STR0004) //"Formulário LPCO"
   endif

Return oModel

//CRF
*------------------------*
Static Function ViewDef()
   *------------------------*
   Local oModel    := FWLoadModel("EICSJJ")
   Local oStruSJJ  := FWFormStruct( 2, "SJJ")
   Local oStEKL
   Local oView

   oView := FWFormView():New()
   oView:SetModel( oModel )

   oView:CreateFolder( 'SJJFOLDER' ) //, 'TELA')
   oView:AddSheet('SJJFOLDER',"OA",STR0003) //"Orgão Anuente"
   oView:CreateHorizontalBox( 'BOXSJJ', 50, , , 'SJJFOLDER', 'OA')
   oView:AddField('VIEW_SJJ', oStruSJJ , "SJJMASTER" )
   oView:SetOwnerView( 'VIEW_SJJ' , 'BOXSJJ' )
   oView:EnableTitleView('VIEW_SJJ', STR0001 )

   if avflags("FORM_LPCO")
      oStEKL := FWFormStruct( 2, "EKL")
      oView:CreateHorizontalBox( 'BOXEKL', 50 , , , 'SJJFOLDER', 'OA')
      oView:AddGrid( "VIEW_EKL", oStEKL, "EKLDETAIL")
      oView:SetOwnerView( 'VIEW_EKL', 'BOXEKL' )
      oView:EnableTitleView('VIEW_EKL', STR0004 ) //"Formulário LPCO"
      oView:SetViewProperty('VIEW_EKL', "GRIDDOUBLECLICK" , {{|oView,cFieldName,nLineGrid,nLineModel| showMemo(oView,cFieldName,nLineGrid,nLineModel)}} )
   endif

   //Habilita ButtonsBar
   oView:EnableControlBar(.T.)

Return oView
/*/
   Function showMemo(oView,cFieldName,nLineGrid,nLineModel)
   Função para exibir o campo meemo do grid EKL
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function showMemo(oView,cFieldName,nLineGrid,nLineModel)
   Local oModel   := FWModelActive()
   Local oMdlEKL  := oModel:GetModel("EKLDETAIL")

   eecView( oMdlEKL:getValue("EKL_FORMJS"), "Modelo LPCO")

return .F.

/*/
   Function EKLModal()
   Função para o combo box dos campos EKL e EKM modal
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function EKLModal()
   Local cRet := ""

   cRet := "1=Importação;2=Exportação"

Return cRet
/*---------------------------------------------------------------------*
 | Func:  eklRelacao                                                   |
 | Autor: Miguel Gontijo                                               |
 | Data:  17/11/2020                                                   |
 | Desc:  Carregar valores para determinados campos, como os virtuais  |
 | Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Function EKLRelacao(cCpo)
   Local oMdlAtv := FWModelActive()
   Local oModel  := If( !(oMdlAtv:CID == "EICSJJ") ,  FWLoadModel("EICSJJ") , FWModelActive() )
   Local oMdl_EKL
   Local cValue   := ""

   If !oModel:IsActive()
      oModel:Activate()
   EndIf

   oMdl_EKL := oModel:GetModel("EKLDETAIL")

   If oModel:GetOperation() <> 3
      Do Case
         Case cCpo == 'EKL_MODALI' .And. ValType(oMdl_EKL) == "O"
            cValue := If( Left(EKL->EKL_CODFOR,1) == "I" , "1" , "2" )
      EndCase
   EndIf

Return cValue
/*/
   Function SJJIntgPU(lIntegAll)
   Função a ser chamada no menu outras ações para iniciar a integração de um ou de todos
   os registros de órgãos anuentes formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function SJJIntgPU(lIntegAll)
   Local cURLTest       := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
   Local cURLProd       := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br
   Local lIntgProd      := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   Local cURLAuth       := "/portal/api/autenticar"
   Local cPUAuth        := ""
   Local cErros         := ""
   Local lRet           := .T.
   Local aSJJInteg      := {}
   Local cLib

   Private lAutenticou  := .F.
   Private lErroGrave   := .F.
   Private lProcessou   := .F.

   Default lIntegAll    := .F.
   GetRemoteType(@cLib)
   If 'HTML' $ cLib .And. ! lIntgProd
      easyhelp(STR0036,STR0010,STR0037) //"Integração com Portal Único não disponível no smartclientHtml"  "Utilizar o smartclient aplicativo"
   Else      
      begin sequence
         if ! lIntgProd
            if ! msgnoyes( STR0022 + ENTER   ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
                  + STR0023  + ENTER   ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                  + STR0024  + ENTER   ; // "Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 1."
                  + STR0025  , STR0009 ) // "Deseja Prosseguir?" // "Atenção"
               lRet := .F.
               break
            else
               cPUAuth  := cURLTest+cURLAuth
               cUrlPU   := cURLTest
            endif
         else
            cPUAuth  := cURLProd+cURLAuth
            cUrlPU   := cURLProd
         endif

         //busca os orgão anuentes, formulário lpco, ncm x form lpco e prod x ncm a serem atualizados
         aSJJInteg := SearchInteg(lIntegAll)
         msAguarde( {|lFim| lRet := IntegPU(lIntegAll,@lFIm,cPUAuth,cUrlPU,@cErros,@aSJJInteg) } , STR0020, STR0021 ) // "Integração Portal Único", "Aguarde a integração..."


         if lRet .and. empty(cErros)
            MsgInfo(STR0011, STR0010) //"Integração realizada com sucesso" ,"Aviso"
         else
            if ! empty(cErros)
               EECView(cErros,STR0009) //"Atenção"
            Else
               MsgInfo(STR0012 ,STR0010) // "Integração cancelada pelo usuário!" , "Aviso"
            endif
         endif
      end sequence
   EndIf   

Return
/*/
   Function SJJIntgPU(lIntegAll)
   Função a ser chamada no menu outras ações para iniciar a integração de um ou de todos
   os registros de órgãos anuentes formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Function IntegPU(lIntegAll,lFIm,cPUAuth,cUrlPU,cErros,aSJJInteg)
   Local cURLFormLPCO:= "/talpco/api/ext/lpco/modelo/consulta/" ///talpco/api
   Local cURLMdlLPCO := "/talpco/api/ext/lpco/modelo/"
   Local cUrl        := ""
   Local lRet        := .T.
   Local oEasyJS
   Local oProcess

   begin sequence

      // crio somente um objeto para easyjs
      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cPUAuth //cUrlPU + '/portal/api'
      oEasyJS:SetTimeout(120)
      oEasyJS:AddLib( jsFormlpco( cPUAuth ))

      if oEasyJS:Activate(.T.)
         oEasyJS:SetTimeout(0)
         MsProcTxt(STR0026) // "Autenticando com Portal Único"
         oProcess := easyProgress():New()
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO("AUTH",@aSJJInteg,cPUAuth,@cUrl,@oProcess,@lEnd,@cErros,@oEasyJS) }, STR0026 ) // "Autenticando com Portal Único"
         oProcess:init()

         if ! lRet .or. ! empty(cErros)
            cErros += ENTER + STR0035 //"Não possível autenticar no Portal Único Siscomex, verifique o endereço nos parâmetros e verifique se o portal está no ar."
            break
         endif

         MsProcTxt(STR0027) // "Buscando Formulários LPCO"
         cUrl := cUrlPU + cURLFormLPCO
         oProcess := easyProgress():New()
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO("FORM",@aSJJInteg,cPUAuth,@cUrl,@oProcess,@lEnd,@cErros,@oEasyJS) }, STR0027 ) //"Buscando Formulários LPCO"
         oProcess:init()

         if ! lRet //.or. lErroGrave
            break
         endif

         MsProcTxt(STR0028) // "Buscando Modelos dos Formulários LPCO"
         lProcessou := .F.
         cUrl := cUrlPU + cURLMdlLPCO
         oProcess := easyProgress():New()
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO("MDL_FORM",@aSJJInteg,cPUAuth,@cUrl,@oProcess,@lEnd,@cErros,@oEasyJS) }, STR0028 ) // "Buscando Modelos dos Formulários LPCO"
         oProcess:init()

         if ! lRet //.or. lErroGrave
            break
         endif

         MsProcTxt(STR0029) // "Buscando Modelos das NCMs associadas aos formulários"
         lProcessou := .F.
         cUrl := cUrlPU + cURLMdlLPCO
         oProcess := easyProgress():New()
         oProcess:setProcess( {|lEnd| lRet := IntegLPCO("NCM",@aSJJInteg,cPUAuth,@cUrl,@oProcess,@lEnd,@cErros,@oEasyJS) }, STR0029 ) // "Buscando Modelos das NCMs"
         oProcess:init()
      else
         cErros += STR0030 // EasyHelp( STR0030 ) // "Falha na integração"
         lRet := .F.
      endif

   end sequence
return lRet
/*/
   Function IntegLPCO(cTipo,aSJJInteg,cPUAuth,cUrl,oProcess,lEnd,cErros,oEasyJS)
   Função que monta a lista de formulários LPCO e NCM x Form LPCO com base no array de itens a serem integrados e dispara a integração
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function IntegLPCO(cTipo,aSJJInteg,cPUAuth,cUrl,oProcess,lEnd,cErros,oEasyJS)
   Local lRet        := .T.
   Local w           := 0
   Local y           := 0
   Local nRegua      := iif( cTipo == "AUTH" , 1 , 0 )
   Local aBuffer     := {}
   Local cLista      := ""
   Local cAux        := ""

   begin sequence

      if cTipo <> "AUTH"

         cLista := "["
         for w := 1 to len(aSJJInteg)

            If oProcess:lAbort
               lRet := .F.
               break
            EndIf

            if cTipo == "FORM"
               nRegua++

               if len(cLista) == 1
                  cLista += "'" + alltrim(aSJJInteg[w][1][1]) + "'"
               else
                  cLista += ",'"+ alltrim(aSJJInteg[w][1][1]) + "'"
               endif

            elseif cTipo == "MDL_FORM"

               if len(aSJJInteg[w][1][3]) > 0
                  nRegua += len(aSJJInteg[w][1][3])
                  if len(cLista) == 1
                     cAux := "[ '" + alltrim(aSJJInteg[w][1][1]) + "' , ["
                  else
                     cAux := ", [ '" + alltrim(aSJJInteg[w][1][1]) + "' , ["
                  endif

                  for y := 1 to len(aSJJInteg[w][1][3])
                     if y == 1
                        cAux += "'" + aSJJInteg[w][1][3][y][1] + "'"
                     else
                        cAux += ",'" + aSJJInteg[w][1][3][y][1] + "'"
                     endif
                  next
                  cAux += "]]"
               endif
               cLista += cAux

            elseif cTipo == "NCM"

               //verifica se tem ncm para os formulários do orgão anuente
               if len(aSJJInteg[w][1][4]) > 0
                  nRegua += len(aSJJInteg[w][1][4])

                  if len(cLista) > 1
                     cLista += ","
                  endif

                  // percorre todas NCMs cadastradas para o formulário LPCO
                  for y := 1 to len(aSJJInteg[w][1][4])
                     // nAux := aSJJInteg[w][1][4][y][2]
                     // EKM->(dbgoto(nAux))
                     if empty(cAux)
                        cAux += "['" + alltrim(aSJJInteg[w][1][4][y][1]) + "', '" + alltrim(aSJJInteg[w][1][4][y][2]) + "', '" + alltrim(aSJJInteg[w][1][4][y][3]) + "']"
                     else
                        cAux += ",['" + alltrim(aSJJInteg[w][1][4][y][1]) + "', '" + alltrim(aSJJInteg[w][1][4][y][2]) + "', '" + alltrim(aSJJInteg[w][1][4][y][3]) + "']"
                     endif
                  next

                  cLista += cAux
                  cAux  := ""
               endif
            endif
         next
         cLista += "]"
      endif

      oProcess:SetRegua(nRegua)

      if cTipo == "AUTH"

         oEasyJS:runJS( "autenticar(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := SJJBufferJS(x,cTipo,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS) }, {|x|  lErroGrave := .T., cErros += x } ) //Executando um javascript de forma Síncrona

      elseif cTipo == "FORM"

         // roda função js que consulta os formulários dos orgãos
         oEasyJS:runJS( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getFormOrgaos(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := SJJBufferJS(x,cTipo,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS) }, {|x|  lErroGrave := .T., cErros += x } ) //Executando um javascript de forma Síncrona

      elseif cTipo == "MDL_FORM"

         // roda função js que consulta os formulários dos orgãos
         oEasyJS:runJS( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getModelForms(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := SJJBufferJS(x,cTipo,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS) }, {|x|  lErroGrave := .T., cErros += x } ) //Executando um javascript de forma Síncrona

      elseif cTipo == "NCM"

         // roda função js que consulta os formulários dos orgãos
         oEasyJS:runJS( "cLista = " + cLista + "; cUrlAPI = '" + cUrl + "' ; getModelNCM(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := SJJBufferJS(x,cTipo,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS) }, {|x|  lErroGrave := .T., cErros += x } ) //Executando um javascript de forma Síncrona

      endif

      // função que processa o buffer de retorno do JS
      lRet := procBuffer(cTipo,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS)

   end sequence

return lRet
/*/
   Function procBuffer(cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Função que processa o buffer alimentado pela integração com JS
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function procBuffer(cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Local lRet  := .T.

   While (Len(aBuffer) > 0 .Or. !lProcessou) .And. !lErroGrave

      if cAcao == "AUTH"
         if lAutenticou
            oProcess:incRegua()
            exit
         endif

      elseif cAcao $ "FORM|MDL_FORM|NCM"

         if len(aBuffer) > 0
            if Valtype(oProcess) == 'O'
               oProcess:incRegua()
            endif
            grvRetFormLPCO(cAcao,@aSJJInteg,aBuffer[1],@oProcess,@cErros)
            aDel(aBuffer, 1)
            aSize(aBuffer,Len(aBuffer)-1)
         else
            sleep(200)
         endif

      endif

      if Valtype(oProcess) == 'O'
         oProcess:refresh()
         if oProcess:lAbort
            lRet := .F.
            oEasyJS:runJS( "lFim = true; console.log('fim')" )
            exit
         endif
      endif

   enddo

   if lErroGrave
      lRet := .F.
   endif

return lRet
/*/
   Function SJJBufferJS(cRetJson,cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Função que alimenta o buffer com o retorno das integrações
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function SJJBufferJS(cRetJson,cAcao,cErros,aBuffer,aSJJInteg,oProcess,lAutenticou,lProcessou,oEasyJS)
   Local lRet := .T.

   if cAcao == "AUTH"

      If Alltrim(cRetJson) == 'S'
         lAutenticou := .T.
      else
         lRet := .F.
      Endif

   elseif cAcao $ "FORM|MDL_FORM|NCM"

      If upper(Alltrim(cRetJson)) == 'PROCESSOU'
         lProcessou := .T.
      Else
         aAdd(aBuffer, cRetJson)
      Endif

   Endif

   if ! isincallstack("procBuffer") .and. lProcessou
      lRet := procBuffer(cAcao,@cErros,@aBuffer,@aSJJInteg,@oProcess,@lAutenticou,@lProcessou,@oEasyJS)
   endif

return lRet
/*/
   Function grvRetFormLPCO(cTipo,aSJJInteg,cBuffer,oProcess,cErros)
   Função que grava o retorno das integrações nos registros de formulários LPCO e NCM x Form LPCO
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
static function grvRetFormLPCO(cTipo,aSJJInteg,cBuffer,oProcess,cErros)
   Local cNome    := ""
   Local cCodigo  := ""
   Local cOrgao   := ""
   Local cModelo  := ""
   Local aJson    := {}
   Local lReclock := .F.
   Local lGrava   := .F.
   Local w        := 1
   Local nPosSJJ  := 0
   Local nPosEKL  := 0
   Local xRetJson
   Local oJson

   begin sequence
      if ! empty(cBuffer)

         if cTipo == "FORM"

            oJson    := JsonObject():New()
            xRetJson := oJson:FromJson(cBuffer)
            if valtype(xRetJson) == "U"
               if valtype(oJson:GetJsonObject("ret")) == "A"
                  aJson := oJson:GetJsonObject("ret")
                  cOrgao := oJson:GetJsonText("OA")
               else
                  cErros += STR0015 + ENTER + oJson:toJson() + ENTER //"Arquivo de retorno sem itens!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0016 + ENTER  + oJson:toJson() + ENTER //"Arquivo de retorno inválido!"
            endif

            if ! empty(cOrgao) .and. (nPosSJJ := ascan(aSJJInteg, {|x| alltrim(x[1][1]) == cOrgao })) > 0

               nAux := aSJJInteg[nPosSJJ][1][2]
               SJJ->(dbgoto(nAux))

               for W := 1 to len(ajson)

                  cNome    := aJson[w]:GetJsonText("nome")
                  cCodigo  := aJson[w]:GetJsonText("codigo")

                  // caso tenha o retorno de um novo formulário não registrado no banco
                  if ! EKL->(dbsetorder(1),dbseek(xfilial("EKL")+SJJ->JJ_CODIGO+ avkey(cCodigo,"EKL_CODFOR")))
                     lGrava := .T.
                     lReclock := .T.
                  else
                     // caso tenha tenha verifica se está na lista de itens a ser atualizado
                     if len(aSJJInteg[nPosSJJ][1][3]) > 0 .and. (nPosEKL := ascan(aSJJInteg[nPosSJJ][1][3], { |x| alltrim(x[1]) == alltrim(cCodigo) })) > 0
                        nAux := aSJJInteg[nPosSJJ][1][3][nPosEKL][2]
                        EKL->(dbgoto( nAux ))
                        lGrava := .T.
                        lReclock := .F.
                     endif
                  endif

                  if lGrava

                     reclock("EKL",lReclock)
                     EKL->EKL_FILIAL   := xfilial("EKL")
                     EKL->EKL_CODFOR   := cCodigo
                     EKL->EKL_CODIGO   := SJJ->JJ_CODIGO
                     EKL->EKL_DESC     := cNome
                     EKL->(msunlock())

                     lGrava := .F.
                     // Adiciona o novo formulário no controle para as próximas consultas e atualizações
                     if lReclock
                        lReclock := .F.
                        aadd(aSJJInteg[nPosSJJ][1][3], { avkey(cCodigo,"EKL_CODFOR") , EKL->(recno()) , {} } )
                     endif

                  endif
               next
            endif

         elseif cTipo == "MDL_FORM"

            oJson    := JsonObject():New()
            xRetJson := oJson:FromJson(cBuffer)
            if valtype(xRetJson) == "U"
               if valtype(oJson:GetJsonObject("modelo")) == "J" .and. valtype(oJson:GetJsonObject("modelo"):GetJsonObject("modelo")) == "J"
                  cOrgao  := oJson:GetJsonText("anuente")
                  cCodigo := oJson:GetJsonText("formulario")
                  cModelo := oJson:GetJsonText("modelo")
               else
                  cErros += STR0031 + ENTER  + oJson:toJson() + ENTER // "Arquivo de retorno sem o modelo do formulário!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0016 + ENTER + oJson:toJson() + ENTER //"Arquivo de retorno inválido!"
            endif

            if ! empty(cOrgao) .and. (nPosSJJ := ascan(aSJJInteg, {|x| alltrim(x[1][1]) == cOrgao })) > 0

               // nAux := aSJJInteg[nPosSJJ][1][2]
               // SJJ->(dbgoto(nAux))

               if len(aSJJInteg[nPosSJJ][1][3]) > 0 .and. (nPosEKL := ascan(aSJJInteg[nPosSJJ][1][3], { |x| alltrim(x[1]) == alltrim(cCodigo) })) > 0
                  nAux := aSJJInteg[nPosSJJ][1][3][nPosEKL][2]
                  EKL->(dbgoto( nAux ))
                  reclock("EKL",.F.)
                  EKL->EKL_DATA     := dDatabase
                  EKL->EKL_HORA     := strtran(time(),":","")
                  EKL->EKL_FORMJS   := cModelo
                  EKL->(msunlock())
               endif
            endif

         elseif cTipo == "NCM"

            oJson    := JsonObject():New()
            xRetJson := oJson:FromJson(cBuffer)
            if valtype(xRetJson) == "U"
               if valtype(oJson:GetJsonObject("modeloncm")) == "J" .and. valtype(oJson:GetJsonObject("modeloncm"):GetJsonObject("ncm")) == "C"
                  cOrgao  := oJson:GetJsonText("anuente")
                  cCodigo := oJson:GetJsonText("formulario")
                  cNCM    := oJson:GetJsonText("ncm")
                  cModelo := oJson:GetJsonText("modeloncm")
               else
                  cErros += STR0032 + ENTER  + oJson:toJson() + ENTER//"Arquivo de retorno sem o modelo da NCM!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0016 + ENTER  + oJson:toJson() + ENTER // "Arquivo de retorno inválido!"
            endif

            if ! empty(cOrgao) .and. (nPosSJJ := ascan(aSJJInteg, {|x| alltrim(x[1][1]) == cOrgao })) > 0

               // nAux := aSJJInteg[nPosSJJ][1][2]
               // SJJ->(dbgoto(nAux))

               if len(aSJJInteg[nPosSJJ][1][4]) > 0 .and. (nPosEKL := ascan(aSJJInteg[nPosSJJ][1][4], { |x| alltrim(x[2]) == alltrim(cCodigo) .and. alltrim(x[3]) == alltrim(cNCM) })) > 0
                  nAux := aSJJInteg[nPosSJJ][1][4][nPosEKL][4]
                  EKM->(dbgoto( nAux ))
                  reclock("EKM",.F.)
                  EKM->EKM_DATA   := dDatabase
                  EKM->EKM_HORA   := strtran(time(),":","")
                  EKM->EKM_FRMDEF := cModelo
                  EKM->(msunlock())
               endif
            endif

         endif
      endif
   end sequence

return
/*/
   Function jsFormlpco(cPUAuth)
   Gera os scripts para autenticar e consumir serviços de integração do portaul unico através do easyjs
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function jsFormlpco(cPUAuth)
   Local cVar

   begincontent var cVar
      var lFim = false;
      var XCSRFToken = '';
      var SetToken = '';
      var cLista = '';
      var cUrlAPI = '';

      function autenticar(retAdvpl,retAdvplChunk,retAdvplError){
         fetch( '%Exp:cPUAuth%', {
            method: 'POST',
            mode: 'cors',
            headers: {
               'Content-Type': 'application/json',
               'Role-Type': 'IMPEXP',
            },
         })
         .then( res => {
            if (res.status == '200') {
               XCSRFToken = res.headers.get('X-CSRF-Token');
               SetToken = res.headers.get('Set-Token');
               retAdvpl('S');
               res.json();
            }else{
               retAdvplError( res.json() );
               return res
            }
         })
         .catch((e) => { retAdvplError(e) });
      }

      function getFormOrgaos(retAdvpl,retAdvplChunk,retAdvplError){
         if (XCSRFToken && SetToken){
            if (cLista) {
               var aLista  = cLista;
               var cProc = () => {
                  var cProcLista = aLista.shift();
                  if (cProcLista && !lFim ){
                        fetch( cUrlAPI + cProcLista, {
                           method: 'GET',
                           mode: 'cors',
                           headers: {
                              'Content-Type': 'application/json',
                              "Authorization": SetToken,
                              "X-CSRF-Token":  XCSRFToken,
                              },
                        })
                        .then( (res) => res.json() )
                        .then( (json) => { retAdvplChunk({OA:cProcLista,ret:json}) ; cProc() })
                        .catch( (e)  => { retAdvplError(e) });
                  } else {
                     retAdvpl("processou")
                  }
               }
               cProc();
            } else {
               retAdvplError("Lista Inválida!")
            }
         } else {
            retAdvplError("Não Autenticado!")
         }
      }

      function getModelForms(retAdvpl,retAdvplChunk,retAdvplError){
         if (XCSRFToken && SetToken){
            if (cLista) {
               var aLista = cLista;
               var cProc = () => {
                  var aAux = aLista.shift();
                  if (aAux && !lFim) {
                     var cAnuente = aAux.shift();
                     var aFormularios = aAux.shift();

                     var cModelos = () => {
                        var cAnu = cAnuente;
                        var cCodigo = aFormularios.shift();
                        if (cCodigo && !lFim) {
                              fetch( cUrlAPI + cCodigo, {
                                 method: 'GET',
                                 mode: 'cors',
                                 headers: {
                                          'Content-Type': 'application/json',
                                          "Authorization": SetToken,
                                          "X-CSRF-Token":  XCSRFToken,
                                          },
                              })
                              .then( (res) => res.json() )
                              .then( (res) => { retAdvplChunk( { anuente:cAnuente, formulario:cCodigo, modelo:res } ) ; cModelos() })
                              // .then( (res) => { retAdvplChunk( { anuente:cAnuente, formulario:cCodigo, modelo:res } ) ; setTimeout(()=>{cModelos()},50000) })
                              .catch( (e)  => { retAdvplError(e) });
                        } else {
                           cProc();
                        }
                     }
                     cModelos();

                  } else {
                     retAdvpl("processou");
                  }
               }
               cProc();

            } else {
               retAdvplError("Lista Inválida!");
            }
         } else {
            retAdvplError("Não Autenticado!");
         }
      }

      function getModelNCM(retAdvpl,retAdvplChunk,retAdvplError){
         if (XCSRFToken && SetToken){
            if (cLista) {
               var aLista = cLista;
               var cProc = () => {
                  var aAux = aLista.shift();
                  if (aAux && !lFim) {
                     var cAnuente    = aAux.shift();
                     var cFormulario = aAux.shift();
                     var cNCM        = aAux.shift();
                     // console.log( "Anuente: " + cAnuente + " - Form: " + cFormulario + " - NCM: " + cNCM );
                     fetch( cUrlAPI + cFormulario + '/' + cNCM, {
                           method: 'GET',
                           mode: 'cors',
                           headers: {
                                 'Content-Type': 'application/json',
                                 "Authorization": SetToken,
                                 "X-CSRF-Token":  XCSRFToken,
                                 },
                     })
                     .then( (res) => res.json() )
                     .then( (res) => { retAdvplChunk({ anuente:cAnuente, formulario:cFormulario, ncm:cNCM, modeloncm:res }); cProc() })
                     .catch( (e)  => { retAdvplError(e) })
                  }else{
                     retAdvpl("processou")
                  }
               }
               cProc();
            } else {
               retAdvplError("Lista Inválida!");
            }
         } else {
            retAdvplError("Não Autenticado!");
         }
      }

   endcontent

Return cVar

/*/
   Function SearchInteg(lIntegAll)
   Função que busca os registros de órgãos anuentes a serem atualizados pela integração com o portal único
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function SearchInteg(lIntegAll)
   Local lIntegPerg  := .F.
   Local aRet        := {}

   if VldInteg(lIntegAll)
      if IntegPerg()
         lIntegPerg := .T.
      endif
   endif

   if lIntegAll
      SJJ->(dbsetorder(1),dbSeek(xFilial("SJJ")))
      // JJ_FILIAL+JJ_CODIGO - Orgão Anuente
      while SJJ->(!eof()) .and. SJJ->JJ_FILIAL == xfilial("SJJ")
         //Se o registro estiver ativo
         if SJJ->JJ_MSBLQL == "2"
            aadd(aRet, aclone(buildArraySJJ(lIntegPerg)))
         endif
         SJJ->(dbskip())
      enddo
   else
      //Se o registro estiver ativo
      if SJJ->JJ_MSBLQL == "2"
         aadd(aRet, aclone(buildArraySJJ(lIntegPerg)))
      endif
   endif

Return aRet
/*/
   Function buildArraySJJ(lIntegPerg)
   Função que constroi um array de controle para a atualização dos registros com a integração através do portal único
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function buildArraySJJ(lIntegPerg)
   Local aRet        := {}
   Local aFormLPCO   := {}
   Local aFormNCM    := {}
   // Local aProdNCM    := {}

   // EKL_FILIAL+EKL_CODIGO+EKL_CODFOR - Formulário LPCO
   if EKL->(dbsetorder(1),dbseek(xFilial("EKL")+SJJ->JJ_CODIGO))
      while EKL->(!eof()) .and. xFilial("EKL")+EKL->EKL_CODIGO == SJJ->JJ_FILIAL+SJJ->JJ_CODIGO

         if (lIntegPerg .and. EKL->EKL_DATA == dDatabase) .or. (empty(EKL->EKL_DATA)) .or. (!empty(EKL->EKL_DATA) .and. EKL->EKL_DATA < dDatabase)
            // aFormNCM := {}
            // EKM_FILIAL+EKM_ORGANU+EKM_FRMLPC+EKM_NCM - NCM x Formulário LPCO
            if EKM->(dbsetorder(1),dbseek(xFilial("EKM")+EKL->EKL_CODIGO+EKL->EKL_CODFOR))
               while EKM->(!eof()) .and. EKM->EKM_FILIAL+EKM->EKM_ORGANU+EKM->EKM_FRMLPC == EKL->EKL_FILIAL+EKL->EKL_CODIGO+EKL->EKL_CODFOR

                  if (lIntegPerg .and. EKM->EKM_DATA == dDatabase) .or. (empty(EKM->EKM_DATA)) .or. (!empty(EKM->EKM_DATA) .and. EKM->EKM_DATA < dDatabase)
                     aadd(aFormNCM, { EKM->EKM_ORGANU, EKM->EKM_FRMLPC, EKM->EKM_NCM, EKM->(recno()) })
                  endif
                  EKM->(dbskip())
               enddo
            endif

            aadd(aFormLPCO, { EKL->EKL_CODFOR, EKL->(recno()) })
         endif

         EKL->(dbskip())
      enddo
   endif
   aadd(aRet, { SJJ->JJ_CODIGO, SJJ->(recno()) , aClone(aFormLPCO), aClone(aFormNCM) })

Return aRet
/*/
   Function VldInteg(lIntegAll)
   Função que valida a existência de registros atualizados com a data do database do sistema,
   valida os formulários LPCO, ncm x form LPCO e os produtos por ncm
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function VldInteg(lIntegAll)
   Local lRet := .F.

   begin sequence
      if lIntegAll

         // JJ_FILIAL+JJ_CODIGO - Orgão Anuente
         SJJ->(dbsetorder(1),dbSeek(xFilial("SJJ")))
         while SJJ->(!eof()) .and. SJJ->JJ_FILIAL == xfilial("SJJ")
            if SJJ->JJ_MSBLQL == "2"
               // EKL_FILIAL+EKL_CODIGO+EKL_CODFOR - Formulário LPCO
               if EKL->(dbsetorder(1),dbseek(xFilial("EKL")+SJJ->JJ_CODIGO))
                  while EKL->(!eof()) .and. xFilial("EKL")+EKL->EKL_CODIGO == SJJ->JJ_FILIAL+SJJ->JJ_CODIGO
                     if EKL->EKL_DATA == dDatabase
                        lRet := .T.
                        break
                     endif
                     // EKM_FILIAL+EKM_ORGANU+EKM_FRMLPC+EKM_NCM - NCM x Formulário LPCO
                     if EKM->(dbsetorder(1),dbseek(xFilial("EKM")+EKL->EKL_CODIGO+EKL->EKL_CODFOR))
                        while EKM->(!eof()) .and. EKM->EKM_FILIAL+EKM->EKM_ORGANU+EKM->EKM_FRMLPC == EKL->EKL_FILIAL+EKL->EKL_CODIGO+EKL->EKL_CODFOR
                           if EKM->EKM_DATA == dDatabase
                              lRet := .T.
                              break
                           endif
                           EKM->(dbskip())
                        enddo
                     endif
                     EKL->(dbskip())
                  enddo
               endif
            endif
            SJJ->(dbskip())
         enddo

      else

         if SJJ->JJ_MSBLQL == "2"
            if EKL->(dbsetorder(1),dbseek(xFilial("EKL")+SJJ->JJ_CODIGO))
               while EKL->(!eof()) .and. xFilial("EKL")+EKL->EKL_CODIGO == SJJ->JJ_FILIAL+SJJ->JJ_CODIGO
                  if EKL->EKL_DATA == dDatabase
                     lRet := .T.
                     break
                  endif
                  // EKM_FILIAL+EKM_ORGANU+EKM_FRMLPC+EKM_NCM - NCM x Formulário LPCO
                  if EKM->(dbsetorder(1),dbseek(xFilial("EKM")+EKL->EKL_CODIGO+EKL->EKL_CODFOR))
                     while EKM->(!eof()) .and. EKM->EKM_FILIAL+EKM->EKM_ORGANU+EKM->EKM_FRMLPC == EKL->EKL_FILIAL+EKL->EKL_CODIGO+EKL->EKL_CODFOR
                        if EKM->EKM_DATA == dDatabase
                           lRet := .T.
                           break
                        endif
                        EKM->(dbskip())
                     enddo
                  endif
                  EKL->(dbskip())
               enddo
            endif
         endif

      endif
   end sequence

Return lRet
/*/
   Function IntegPerg()
   Função para centralizar a pergunta sobre atualizar os registros que
   já foram atualizados com a data igual a database do sistema
   @author Miguel Prado Gontijo
   @since 17/11/2020
   @version 1
/*/
Static Function IntegPerg()
   Local lRet := .T.

   if ! msgyesno(STR0018) // "Há formulários ou formulários por NCM atualizados hoje. Deseja atualizar novamente esses mesmos formulários?"
      lRet := .F.
   endif

Return lRet

