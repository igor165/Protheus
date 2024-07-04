#INCLUDE "AGRA970.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#DEFINE _CRLF CHR(13)+CHR(10)

/** {Protheus.doc} AGRA970
Variáveis de Uso na Aprovação
@param: 	Nil
@author: 	Marcelo Ferrari
@since: 	26/12/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA970()
Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJ4" )
oMBrowse:SetDescription( STR0001 ) //Variáveis de Uso na Aprovação
oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marcelo R. Ferrari
@since: 	26/12/2016
@Uso: 		AGRA970
*/
Static Function MenuDef()
   Local aRotina := {}
   
   aAdd( aRotina, { STR0002, 'PesqBrw'        , 0, 1, 0, .T. } )   // Pesquisar
   aAdd( aRotina, { STR0003, 'ViewDef.AGRA970', 0, 2, 0, Nil } )   //Visualizar
   aAdd( aRotina, { STR0004, 'ViewDef.AGRA970', 0, 3, 0, Nil } )   //Incluir
   aAdd( aRotina, { STR0005, 'ViewDef.AGRA970', 0, 4, 0, Nil } )   //Alterar
   //aAdd( aRotina,{ STR0008, 'ViewDef.AGRA970', 0, 5, 0, Nil } )   //Excluir
   aAdd( aRotina, { STR0006, 'ViewDef.AGRA970', 0, 8, 0, Nil } )   //Imprimir
   aAdd( aRotina, { STR0007, 'AGRA970VLG'     , 0, 10, 0, Nil } ) //Histórico

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ModelDef()
   Local oStruNJ4 := FWFormStruct( 1, "NJ4" )
   Local oModel := Nil
    
   oModel := MPFormModel():New( "AGRA970M", /*<bPre >*/ , /*<bPos>*/, /*<commit>*/ {| oModel | AGRA970GRV( oModel ) })
   oModel:AddFields( 'NJ4UNICO', Nil, oStruNJ4 )
   oModel:SetDescription( STR0009 ) //Cadastro de Variáveis de Uso na Aprovação
   oModel:GetModel( 'NJ4UNICO' ):SetDescription( STR0009 ) //Cadastro de Variáveis de Uso na Aprovação

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ViewDef()
   Local oStruNJ4 := FWFormStruct( 2, 'NJ4' )
   Local oModel   := FWLoadModel( 'AGRA970' )
   Local oView    := FWFormView():New()

   oView:SetModel( oModel )
   oView:AddField( 'VIEW_NJ4', oStruNJ4, 'NJ4UNICO' )
   oView:CreateHorizontalBox( 'UM'  , 100 )
   oView:SetOwnerView( 'VIEW_NJ4', 'UM'   )

Return oView

Function AGRA970VLD( oModel )
   local lRet := .T.
Return lRet


/** {Protheus.doc} AGRA950GRV
Funcao para gravar dados adicionais e o modelo de dados
@param:     oModel - Modelo de Dados
@return:    .t.
@author:    Equipe AgroIndustria
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function AGRA970GRV( oModel )
   Local aArea := GetArea()
   Local cTipo := cValToChar(oModel:GetOperation())
   Local cMsg  := ""
   Local cValChave := fwXFilial("NJ4")+NJ4->NJ4_CODIGO+NJ4->NJ4_CHAVE
   Local cQry := ""
   Local cSql := ""
   Local aValores := Nil
   Local lAltera := .F.

   If cTipo = "4" //Alteração
      cQry := GetNextAlias()
      cSql := "select NJ4_CHAVE, NJ4_VALOR, NJ4_SIT from " +RetSqlName("NJ4") +" NJ4 " +;
                 "where NJ4_FILIAL = '" + fwXFilial("NJ4") + "' " +;
                 "and NJ4_CODIGO= '" + NJ4->NJ4_CODIGO + "' " +;
                 " and NJ4.D_E_L_E_T_ = '' "
      cSql := ChangeQuery(cSql)
      dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cQry, .F., .T.)

      If (AllTrim((cQry)->NJ4_CHAVE)) != (AllTrim(oModel:GetVAlue("NJ4UNICO", "NJ4_CHAVE"))) .OR.;
         (AllTrim((cQry)->NJ4_SIT)) != (AllTrim(oModel:GetVAlue("NJ4UNICO", "NJ4_VALOR"))) .OR.;
         (AllTrim((cQry)->NJ4_SIT)) != (AllTrim(oModel:GetVAlue("NJ4UNICO", "NJ4_SIT")))
         
         cMsg := "Alteração da Regra"+_CRLF
         cMsg += "Chave......:"+cValChave+_CRLF
         cMsg += "Situacao...:"+(cQry)->NJ4_SIT+_CRLF
         cMsg += "Parâmetro..:"+(cQry)->NJ4_CHAVE+_CRLF
         cMsg += "Valor......:"+(cQry)->NJ4_VALOR
         lAltera := .T.

         aValores := {}
         aAdd(aValores, "NJ4" )
         aAdd(aValores, cValChave )
         aAdd(aValores, cTipo )
         aAdd(aValores, cMsg )
      EndIF
   EndIf
   
   If ( lAltera) .OR. (oModel:GetOperation() = 5) 
      AGRGRAVAHIS(STR0010,"NJ4",cValChave, cTipo, aValores)	= 1 //Histórico de Variáveis de Uso na Aprovação
   EndIf	
   
   RestArea(aArea)
   
   FWFormCommit(oModel)

Return( .T. )


/** {Protheus.doc} AGRA950VLG
Descrição: Mostra em tela de Historico da NJ4
@param: 	Nil
@author: 	Marcelo R. Ferrari
@since: 	23/12/2016
@Uso: 		AGRA970 
*/
Function AGRA970VLG()
	Local cChaveA := fwXFilial("NJ4")+NJ4->NJ4_CODIGO+NJ4->NJ4_CHAVE
	cChaveA := cChaveA +Space(Len(NK9->NK9_CHAVE)-Len(cChaveA) )
	AGRHISTTABE("NJ4",cChaveA)
Return

