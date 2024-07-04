#INCLUDE "PROTHEUS.CH"

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGPEXSRD   Ё Autor Ё Kelly Soares          Ё Data Ё12/11/2009Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁBiblioteca de Funcoes Genericas para uso em Formulas no SRD Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      Ё Generico                                                   Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё
цддддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддд╢
ЁProgramador Ё Data     Ё BOPS  ЁMotivo da Alteracao                    Ё
цддддддддддддеддддддддддедддддддеддддддддддддддддддддддддддддддддддддддд╢
Ё            Ё          Ё       Ё                                       Ё
юддддддддддддаддддддддддадддддддаддддддддддддддддддддддддддддддддддддддды/*/
/*/
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o	   ЁGetSrd  	    ЁAutorЁKelly Soares       Ё Data Ё11/11/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁObtem as Informacoes do SRD de acordo com parametros para   Ё
Ё          Ёroteiro, periodo, numero de pagto e objeto.                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                      									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso	   ЁGenerica      										    	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function GetSrd( cQueryWhere , lSqlWhere , lTopFilter , cRotPar , cPerPar , cNumPar )

Local aArea := GetArea()

Local cKey
Local cRetOrder
Local lGetSrd
Local nSrdOrder  
                                                                        
IF Empty( cQueryWhere )

	#IFDEF TOP
		cQueryWhere := " RD_FILIAL='" + SRA->RA_FILIAL + "' AND " + "RD_MAT='" + SRA->RA_MAT + "' AND "
		cQueryWhere += " RD_PERIODO='" + cPerPar + "' AND RD_SEMANA='" + cNumPar + "' AND RD_ROTEIR='" + cRotPar + "' AND "
		cQueryWhere += " D_E_L_E_T_<>'*' "
		lSqlWhere	:= .T.
	#ELSE
		cQueryWhere := " RD_PERIODO='" + cPerPar + "' .AND. RD_SEMANA='" + cNumPar + "' .AND. RD_ROTEIR='" + cRotPar + "'"
	#ENDIF

EndIF

cRetOrder := "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA"
nSrdOrder := RetOrder( "SRD" , cRetOrder , .T. )
IF ( nSrdOrder == 0 )
	cRetOrder	:= "RD_FILIAL+RD_MAT"
	nSrdOrder	:= RetOrder( "SRD" , cRetOrder , .F. )
EndIF

IF ( cRetOrder == "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA" )
	cKey	:= ( SRA->( RA_FILIAL + RA_MAT + RA_PROCES ) + cRotPar + cPerPar + cNumPar )
Else
	cKey	:= SRA->( RA_FILIAL + RA_MAT )
EndIF

IF (( ValType( oSRD ) == "O" ) .and.;
	( Len(oSRD:aHeader) > 0 ))
	oSRD:GetCols( nSrdOrder , cKey , cQueryWhere , lSqlWhere )
Else
	oSRD := GetDetFormula():New( "SRD" , nSrdOrder , cKey , cQueryWhere , @lSqlWhere , @lTopFilter )
EndIf

lGetSrd	:= oSRD:GetOk()

RestArea(aArea)

Return ( lGetSrd )
