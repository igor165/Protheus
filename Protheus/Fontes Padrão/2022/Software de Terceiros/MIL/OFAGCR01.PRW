#include 'protheus.ch'

/*/{Protheus.doc} OFAGCR01

	Relat�rios de vendas

    * N�mero de itens com vendas por ano (12, 24 e 36 meses) para itens originais e paralelos
    * Quantidade vendida para itens originais e paralelos:
        - M�s a m�s (12, 24 e 36 meses)
        - Por loja
        - Por item

	@type function
	@author Vinicius Gati
	@since 06/10/2017
/*/
function OFAGCR01()


return


Static Function DefStrModel()
    Local oStruct  := FWFormModelStruct():New()
    Local bValid   := { || .T.}
    Local bWhen    := { || }
    Local bRelac   := { || }
        
    // TABELA
    oStruct:AddTable( "SM0", {}, "Filiais", {|| })                
        
    // INDICES
    oStruct:AddIndex(1, "1", "M0_CODIGO", "C�d Empresa", "", "", .T.)

    // CAMPOS
    oStruct:AddField( "C�d Empresa"   , "C�d Empresa"    , "FLD_1" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )                              
    oStruct:AddField( "C�d Filial"    , "C�d Filial"     , "FLD_2" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Nome Empresa"  , "Nome Empresa"   , "FLD_3", "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "CNPJ"          , "CNPJ"           , "FLD_4"    , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "UF"            , "UF"             , "FLD_5" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Insc Estadual" , "Insc Estadual"  , "FLD_6"   , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Insc Municipal", "Insc Municipal" , "FLD_7"  , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "C�d Munic"     , "C�d Munic"      , "FLD_8" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
Return oStruct




