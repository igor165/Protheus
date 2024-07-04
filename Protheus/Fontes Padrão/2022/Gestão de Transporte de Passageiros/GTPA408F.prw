#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para a gravação das Escalas de Veículos
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/07/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel    := FwLoadModel("GTPA004")
Local oStrGID	:= oModel:GetModel("GIDMASTER"):GetStruct()
Local oStrGIE	:= oModel:GetModel("GIEDETAIL"):GetStruct()

G408FStruct(oStrGID,oStrGIE)

oModel:GetModel("GIDMASTER"):SetOnlyQuery(.t.)
oModel:GetModel("GIEDETAIL"):SetOnlyQuery(.t.)
oModel:lModify := .t.


Return(oModel)

/*/{Protheus.doc} GA408EStruct
    Função responsável por criar a estrutura dos submodelos, tanto para o model quanto view,
	utilizados pelo MVC. 
    @type  Static Function
    @author(s) 	Fernando Radu Muscalu
				Mick William
    @since 27/03/2017
    @version 1

    @param 	aStrGID, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIDMASTER)
			aStrGIE, objeto, instância da Classe FWFormModelStruct ou FWFormViewStruct (GIEDETAIL)
			
	@return nil, nulo, Sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function G408FStruct(oStrGID,oStrGIE,cTipo)

Local bValid	:= Nil

Default cTipo   := "M"

If ( cTipo == "M" )

	oStrGIE:AddField( 	"",; 			// cTitle
						"Marcar/Desmarcar",; 		// cToolTip
						'GIE_CHECK',; 	// cIdField
						'L', ; 			// cTipo
						1, ; 			// nTamanho
						0, ;		 	// nDecimal
						bValid, ; 		// bValid
						Nil,; 		// bWhen
						Nil, ; 			// aValues/
						Nil, ; 			// lObrigat
						Nil/*{|oModel| G408FSetChecked(oModel) } */, ; 	// bInit ant. ->{|oModel| G408FSetChecked(oModel,"GIE_CHECK") } 
						Nil, ; 			// lKey
						.F., ; 			// lNoUpd
						.T. ) 			// lVirtual	
						
	oStrGIE:AddField( 	"secionado?",; 			// cTitle
						"Marcar/Desmarcar",; 		// cToolTip
						'GIE_SEC',; 	// cIdField
						'C', ; 			// cTipo
						1, ; 			// nTamanho
						0, ;		 	// nDecimal
						Nil,;	 		// bValid
						{||	.T.},; 		// bWhen
						{"1=Sim","2=Não"}, ; 			// aValues/
						Nil, ; 			// lObrigat
						/*{|oModel| G408FSetChecked(oModel,"GIE_SEC") }*/, ; 	// bInit ant. -> {|oModel| G408FSetChecked(oModel,"GIE_SEC") }
						Nil, ; 			// lKey
						.F., ; 			// lNoUpd
						.T. ) 			// lVirtual					

    
EndIf

Return()
