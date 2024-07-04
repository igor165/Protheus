#INCLUDE "PROTHEUS.CH"
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддддд©
ЁFun┤└o    ЁRD0SPFilter  Ё Autor ЁRogerio Ribeiro      Ё Data Ё//          Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RD0                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RD0                   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                               Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico                                                       Ё
цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.            Ё
цддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддд╢
ЁProgramador Ё Data     Ё BOPS/FNC       ЁMotivo da Alteracao              Ё
цддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддд╢
ЁCecilia C.  Ё04/08/2014ЁTQFZO4          ЁIncluido o fonte da 11 para a 12.Ё
юддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддды/*/
Function RD0SPFilter()                              

	Static __cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )
	
	Local cExp:= ".T."       
	Local cUserId
	Local aGrupos

	If __cORGSPFL # "S" 
		Return cExp
	EndIf
	
	cUserId	:= RetCodUsr()
	If cUserId = "000000" 
		Return cExp
	EndIf
	
	aGrupos   := UsrRetGrp(cUserName)
	If (AScan(aGrupos, { |x| x == "000000"}) > 0)
		Return cExp
	EndIf	

Return cExp
