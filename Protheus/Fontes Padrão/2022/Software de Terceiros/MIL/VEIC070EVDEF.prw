#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIC070EVDEF FROM FWModelEvent

	DATA _OpcionalCampoFiltro
	DATA _CorExternaCampoFiltro
	DATA _CorInternaCampoFiltro

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

	METHOD SetOpcionalCampoFiltro()
	METHOD SetCorExternaCampoFiltro()
	METHOD SetCorInternaCampoFiltro()

ENDCLASS

METHOD SetOpcionalCampoFiltro(cCampo) Class VEIC070EVDEF
	self:_OpcionalCampoFiltro := cCampo
Return .t.

METHOD SetCorExternaCampoFiltro(cCampo) Class VEIC070EVDEF
	self:_CorExternaCampoFiltro := cCampo
Return .t.

METHOD SetCorInternaCampoFiltro(cCampo) Class VEIC070EVDEF
	self:_CorInternaCampoFiltro := cCampo
Return .t.

METHOD New() CLASS VEIC070EVDEF

	self:_OpcionalCampoFiltro   := ""
	self:_CorExternaCampoFiltro := ""
	self:_CorInternaCampoFiltro := ""

RETURN .T.

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIC070EVDEF

	Local cSQL

	If cAction <> "SETVALUE"
		Return .t.
	EndIf

	Do Case
	Case cModelID == "LISTA_MARCA"
		If cId == "SELMARCA"
			cSQL := ;
				"UPDATE " + oTResMarca:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VV1_CODMAR = '" + oSubModel:GetValue("MARCACODMAR") + "'"
			oTResMarca:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_MODELO"
		If cId == "SELMODELO"
			cSQL := ;
				"UPDATE " + oTResModelo:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VV1_MODVEI = '" + oSubModel:GetValue("MODMODVEI") + "'"
			oTResModelo:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_OPCIONAL"
		If cId == "SELOPCIONAL"
			cSQL := ;
				"UPDATE " + oTResOpcional:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE " + self:_OpcionalCampoFiltro + " = '" + oSubModel:GetValue("MODOPCION") + "'"
			oTResOpcional:ExecSQL(cSQL )

			//VC070A0013_AtuRelVX5(IIf( xValue , "1" , "0" ), oSubModel:GetValue("MODOPCION"), '068')

		EndIf

	Case cModelID == "LISTA_COREXTERNA"
		If cId == "SELCOREXT"
			cSQL := ;
				"UPDATE " + oTResCorExt:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE " + self:_CorExternaCampoFiltro + " = '" + oSubModel:GetValue("MODCOREXT") + "'"
			oTResCorExt:ExecSQL(cSQL )
			

			//VC070A0013_AtuRelVX5(IIf( xValue , "1" , "0" ), oSubModel:GetValue("MODCOREXT"), '067')

		EndIf

	Case cModelID == "LISTA_CORINTERNA"
		If cId == "SELCORINT"
			cSQL := ;
				"UPDATE " + oTResCorInt:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE " + self:_CorInternaCampoFiltro + " = '" + oSubModel:GetValue("MODCORINT") + "'"
			oTResCorInt:ExecSQL(cSQL )
			//VC070A0013_AtuRelVX5(IIf( xValue , "1" , "0" ), oSubModel:GetValue("MODCORINT"), '066')
		EndIf

	Case cModelID == "LISTA_ANOFABMOD"
		If cId == "SELFABMOD"
			cSQL := ;
				"UPDATE " + oTResAnoFabMod:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VV1_FABMOD = '" + oSubModel:GetValue("MODFABMOD") + "'"
			oTResAnoFabMod:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_SITUACAO"
		If cId == "SELSITUAC"
			cSQL := ;
				"UPDATE " + oTResSituacao:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE SITUACAO = '" + oSubModel:GetValue("SITUACAO") + "'"
			oTResSituacao:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_IMOBILIZADO"
		If cId == "SELIMOB"
			cSQL := ;
				"UPDATE " + oTResImobilizado:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VV1_IMOBI = '" + oSubModel:GetValue("VEICIMOB") + "'"
			oTResSituacao:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_SITVEI"
		If cId == "SELSITVEI"
			cSQL := ;
				"UPDATE " + oTResSitVei:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VV1_SITVEI = '" + oSubModel:GetValue("MODSITVEI") + "'"
			oTResSitVei:ExecSQL(cSQL )
		EndIf

	Case cModelID == "LISTA_EVENTO"
		If cId == "SELEVENTO"
			cSQL := ;
				"UPDATE " + oTResEvento:GetRealName() + ;
				" SET MARCADO = " + IIf( xValue , "1" , "0" ) +;
				" WHERE VJR_EVENTO = '" + oSubModel:GetValue("MODEVENTO") + "'"
			oTResEvento:ExecSQL(cSQL )
		EndIf
	EndCase

RETURN .T.


//Static Function VC070A0013_AtuRelVX5(cMarcacao, cDescricao, cTabela)
//
//	cSQL := "UPDATE " + oTRelVX5:GetRealName() + ;
//		" SET MARCADO = " + cMarcacao +;
//		" WHERE VX5_DESCRI = '" + cDescricao + "'" +;
//		" AND VX5_CHAVE = '" + cTabela + "'"
//	oTRelVX5:ExecSQL(cSQL)
//
//Return