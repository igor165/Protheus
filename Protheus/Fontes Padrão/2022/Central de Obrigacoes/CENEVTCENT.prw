#INCLUDE "TOTVS.CH"

Class CENEVTCENT FROM FWModelEvent
	Method AfterTTS(oModel, cModelId)
	Method New()
  Method Destroy()
End Class

Method New() Class CENEVTCENT
Return

Method Destroy()  Class CENEVTCENT       
Return

Method AfterTTS(oModel, cModelId,oBrwVcto,oBrowseDown) Class CENEVTCENT

	If SELECT("VCTOB3D") > 0
		dbselectarea('VCTOB3D')
		('VCTOB3D')->(DBGOTOP())
		While ('VCTOB3D')->(!Eof())
			Reclock('VCTOB3D',.F.)
			('VCTOB3D')->(DbDelete())
			MsUnlock()
			('VCTOB3D')->(DBSkip())
		EndDo

		If BuscaVctos()
			StaticCall(PLSMVCCENTRAL,CarregaArqTmp)
		EndIf

	EndIf

	If SELECT("TEMPB3D") > 0
		dbselectarea('TEMPB3D')
		('TEMPB3D')->(DBGOTOP())
		While ('TEMPB3D')->(!Eof())
			Reclock('TEMPB3D',.F.)
			('TEMPB3D')->(DbDelete())
			MsUnlock()
			('TEMPB3D')->(DBSkip())
		End Do
		If BuscaB3D()
			StaticCall(PLSMVCCENTRAL,LoadB3DTmp)
		EndIf
	EndIf

Return