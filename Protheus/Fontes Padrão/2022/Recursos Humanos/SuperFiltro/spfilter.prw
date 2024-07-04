#INCLUDE "PROTHEUS.CH"

Static aGrupos	:= {} 
Static cUserId	:= "" 
Static __cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё SPFILTER Ё Autor Ё Igor Franzoi                    Ё Data Ё09/03/2009Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFonte criado para armazenar as funcoes de SuperFiltro                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё                                                                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       Ё Generico                                                             Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё           ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                     Ё
цдддддддддддддддддбддддддддбдддддддддддбдддддддддддддддддддддддддддддддддддддддддд╢
ЁProgramador      Ё Data   Ё BOPS/FNC  Ё  Motivo da Alteracao                     Ё
цдддддддддддддддддеддддддддедддддддддддедддддддддддддддддддддддддддддддддддддддддд╢
ЁCecilia C.       Ё04/08/14ЁTQFZO4     ЁIncluido o fonte da 11 para a 12.         Ё
юдддддддддддддддддаддддддддадддддддддддадддддддддддддддддддддддддддддддддддддддддды/*/


/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSRVSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SRV									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SRV				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 
Function SRVSPFilter()
  	If __cORGSPFL # 'S'
		Return ""
	Endif
Return GetGPEXSpFl("SRV", "RV")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSRYSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SRY									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SRY				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SRYSPFilter() 
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRY", "RY")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCTTSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela CTT									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela CTT				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CTTSPFilter()
	If (__cORGSPFL # 'S') .OR. (!(cModulo $ ("APD","CSA","GPE","PON","RSP","TRM","APT","RPM")))  //superfiltro CTT sС aplicado sobre modulos de RH
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRCHSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RCH									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RCH				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RCHSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCH", "RCH")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRCJSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RCJ									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RCJ				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RCJSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCJ", "RCJ")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSRCSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SRC									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SRC				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SRCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRC", "RC")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSRDSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SRD									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SRD				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SRDSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRD", "RD")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSI3SPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё09/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SI3									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SI3				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SI3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRGBSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё20/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RGB									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RGB				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RGBSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGB", "RGB")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRCOSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё20/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RCO									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RCO				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RCOSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCO", "RCO")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRGCSPFilter	 Ё Autor ЁIgor Franzoi		   Ё Data Ё20/03/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RGC									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RGC				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RGCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGC", "RGC")

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRCPSPFilter	 Ё Autor ЁValdeci Lira		   Ё Data Ё14/05/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela Rcp									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela Rcp				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RCPSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCP", "RCP")
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRCQSPFilter	 Ё Autor ЁValdeci Lira		   Ё Data Ё14/05/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RCQ									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela Rcp				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RCQSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCQ", "RCQ")
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSR3SPFilter	 Ё Autor ЁValdeci Lira		   Ё Data Ё14/05/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SR3									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SR3				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SR3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR3", "R3")
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSR7SPFilter	 Ё Autor ЁValdeci Lira		   Ё Data Ё14/05/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SR7									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela SR7				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function SR7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR7", "R7")
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRG7SPFilter	 Ё Autor ЁValdeci Lira		   Ё Data Ё14/05/2009Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela RG7									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁcExp = Expressao de filtro para a tabela RG7				 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RG7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RG7", "RG7")
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁSPFILTER  ╨Autor  ЁMicrosiga           ╨ Data Ё  04/09/09   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GetGPESpFil(cAlias, cPrefixTable)
	Local aArea 	:= getArea()    
	Local cGrupo	:= ""
	Local cValFil	:= ""
   	Local cRet		:= ""
   	Local cKey		:= "" 
   	Local nGrupo	:= 1
   	Local nMaxGrupo	:= Len(aGrupos)
      
  	If __cORGSPFL # 'S'
		Return cRet
	Endif
	
	aGrupos	:= UsrRetGrp(cUserName)
	cUserId	:= RetCodUsr()
	
  	iif(nMaxGrupo == 0, {|| nMaxGrupo := 1, aAdd(aGrupos, "" )}, .T.)
  	
	If FindFunction(cAlias + "SPFILTER")
		If ( Select( "SRW" ) == 0 )
			ChkFile("SRW")
		EndIf
		
		SRW->(dbSetOrder(RetOrder("SRW","RW_FILIAL+RW_SPFIL+RW_ALIAS+RW_GRUPO+RW_IDUSER")))		
			
		cKey := xFilial("SRW")
		cKey += "1"
		cKey += cAlias     
   		cRet := ""      	
	   		
		/*здддддддддддддддддддддддддддддддддддддддддддддддддд©
		  ЁProcura todas as restricoes que cabem ao usuario, Ё
		  Ёconsidera os grupos e restricao pertencentes a eleЁ
		  юдддддддддддддддддддддддддддддддддддддддддддддддддды*/	
		If ( SRW->( dbSeek(cKey) ) )              
			cCondAux := SRW->RW_FILIAL + SRW->RW_SPFIL + SRW->RW_ALIAS
			While ( SRW->(!Eof()) .AND. cCondAux == cKey ) 
				//Verifica se a restricao se aplica ao usuario
			    If (Empty(SRW->RW_GRUPO) .AND. SRW->RW_IDUSER == cUserId);
			    	.OR. ;
			       ((Empty(SRW->RW_IDUSER) .OR. SRW->RW_IDUSER == cUserId) .AND. aScan(aGrupos, {|x| x == SRW->RW_GRUPO})> 0)
			    	
				   	If(!Empty(cRet))
				   		cRet += " .AND. " + AllTrim(SRW->RW_FILBROW)
				   	Else
				   		cRet:= AllTrim(SRW->RW_FILBROW)
				   	EndIf
				EndIf         
				
				SRW->(dbSkip()) 
				cCondAux := SRW->RW_FILIAL + SRW->RW_SPFIL + SRW->RW_ALIAS
			EndDo
		EndIf
		//-- Desabilita o filtro de filiais para o Brasil, pois o usuario precisa ter visao
		//-- total por exemplo da ficha financeira (SRD).
		IF cPaisLoc <> 'BRA'
			//Se o prefixo da tabela tiver sido mandado com _, retira-o
			cPrefixTable := StrTran( cPrefixTable, "_", "")
			cValFil := " (" + cPrefixTable +"_FILIAL $'" + fValidFil(cAlias) + "') "
			If !Empty(cRet)    
				cRet := cValFil+" .and. "+cRet
			Else
				cRet := cValFil
			EndIf
	    Endif
	EndIf	
	
	RestArea(aArea)
Return cRet                                                         
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁSPFILTER  ╨Autor  ЁMicrosiga           ╨ Data Ё  04/09/09   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function GetGPEXSpFl(cTable, cPrefixTable)
	Local cExp		:= ""
	Local cChkRh	:= ""
	Local cFunName	:= ""

	If __cORGSPFL # 'S' 
		Return cExp
	EndIf

	cUserId	:= RetCodUsr()
	aGrupos   := UsrRetGrp(cUserName)	
	
	If (cUserId = "000000" .or. Empty(cUserId))
		Return cExp
	EndIf

	If (AScan(aGrupos, { |x| x == "000000"}) > 0)
		Return cExp
	EndIf	
	
	//Busca as restricoes para o usuario
	cExp := GetGPESpFil(cTable, cPrefixTable )
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Caso a expressao de filtro seja maior que 4000 caracteres   Ё
	Ё imprime o tamanho no server								  Ё	
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	If ( Len(cExp) > 4000 )
		ConOut("Tamanho: " + Str(Len(cExp)))
	EndIf
		
Return cExp
