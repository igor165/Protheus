#INCLUDE "OGA960.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} OGC010
(Rotina para Consulta da Necessidade de Reserva)
@type function
@author Marcelo Ferrari
@since 20/03/2017AD
@version 1.0
*/
Function OGA960()
   Local oMBrowse := nil 

   PRIVATE _cTabela := "NCS"
   PRIVATE _cNmMdFld := _cTabela+"_Main"    //Nome da estrutura de campos
   PRIVATE aRotina   := MenuDef()  			// Array com opcoes do menu da mBrowse
   PRIVATE _cNmModel := "OGA960"       //Nome do Modelo

   If !OGC180VLDROTINA()    
      Return()
   EndIf
        
   oMBrowse := FWMBrowse():New()
   oMBrowse:SetAlias( "NCS" )
   oMBrowse:SetDescription( STR0001 ) 
   oMBrowse:DisableDetails()
   oMBrowse:SetAttach( .T. )
   oMBrowse:Activate()

Return Nil

Static Function MenuDef()
   Local aRotina := {}
   
   aAdd(aRotina, {'Visualizar', 'VIEWDEF.OGA960', 0, OP_VISUALIZAR, 0, NIL})
   aAdd(aRotina, {'Adicionar' , 'VIEWDEF.OGA960', 0, OP_INCLUIR   , 0, NIL})
   aAdd(aRotina, {'Alterar'   , 'VIEWDEF.OGA960', 0, OP_ALTERAR   , 0, NIL})
   aAdd(aRotina, {'Excluir'   , 'VIEWDEF.OGA960', 0, OP_EXCLUIR   , 0, NIL})
   aAdd(aRotina, {'Imprimir'  , 'VIEWDEF.OGA960', 0, OP_IMPRIMIR  , 0, NIL})
   aAdd(aRotina, {'Copiar'    , 'VIEWDEF.OGA960', 0, OP_COPIA  , 0, NIL})
   
Return aRotina


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	
@since: 	
@Uso: 		
*/
Static Function ModelDef()
   Local oStruTBL := FWFormStruct( 1, "NCS" )
   Local oModel   := MPFormModel():New( "OGA960", , {| oModel | PosModelo( oModel ) })
   Local cDescrip := X2NOME() 
   
   oModel:AddFields( "NCS_Main" , Nil, oStruTBL )
   oModel:SetDescription( cDescrip )
   oModel:GetModel("NCS_Main"):SetDescription( cDescrip ) //Descrição da Tabela

Return( oModel )


Static Function ViewDef()
   Local oStruTBL := FWFormStruct( 2, "NCS" )
   Local oModel   := FWLoadModel( "OGA960" )
   Local oView    := FWFormView():New() 
   Local cNmView  := "VIEW_NCS" 

   oStruTBL:RemoveField("NCS_IDM2M")
   oStruTBL:RemoveField("NCS_IDCTR")
   oStruTBL:RemoveField("NCS_TPORD")
   oStruTBL:RemoveField("NCS_DATAIN")

   oView:SetModel( oModel )
   oView:AddField( cNmView, oStruTBL, "NCS_Main" )
   oView:CreateHorizontalBox( "HB001"  , 100 )
   oView:SetOwnerView( cNmView, "HB001" )
   
Return oView

/*/{Protheus.doc} OGA960VLAM
   Validação para o campo NCS_MESEMB - via dicionario
   @type  Function
   @author claudineia.reinert
   @since 24/06/2020
   @version 1.0
   @return lRet, boolean, retorna .T. ou .F.
   /*/
Function OGA960VLAM()
   Local cAnoMes     := &( ReadVar() ) //EX:202006
   Local lRet        := .T.
   
   If !Empty(cAnoMes)
      cAnoMes := AGRMesAno(cAnoMes, 0)
      If LEN(cAnoMes) < 6 .OR. cAnoMes == "000000" 
         lRet := .F.
      EndIf
   EndIf
   
Return lRet


/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos de Venda
*/
Static Function PosModelo( oModel )
	Local lContinua     := .T.
	Local oModelNCS     := oModel:GetModel( "NCS_Main" )	
    Local cAliasQry     := GetNextAlias()
    Local cCodigo       := oModelNCS:GetValue("NCS_CODIGO")

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        BeginSql Alias cAliasQry
            SELECT NCT_CODNGC 
              FROM %table:NCT%
             WHERE NCT_FILIAL = %xFilial:N79%
               AND NCT_IDCTFT = %Exp:cCodigo%
               AND %notDel%
        EndSQL

        While ((cAliasQry)->(!Eof()))
            IF !Empty((cAliasQry)->NCT_CODNGC)
                lContinua := .F.
                AGRHELP(STR0002,STR0003 +chr(10) + STR0005 + (cAliasQry)->NCT_CODNGC, STR0004 ) //Existem fixações utilizando este contrato futuro. Não é possível a exclusão. //"Remova todos os vínculos para poder excluir este registro."
                exit
            EndIf   
            (cAliasQry)->(dbskip())
        EndDo  

        (cAliasQry)->(dbCloseArea())      
    EndIf

Return lContinua    
