#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GPEXSRD   � Autor � Kelly Soares          � Data �12/11/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Biblioteca de Funcoes Genericas para uso em Formulas no SRD �
�����������������������������������������������������������������������Ĵ
� Uso      � Generico                                                   �
�����������������������������������������������������������������������Ĵ
�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             �
�����������������������������������������������������������������������Ĵ
�Programador � Data     � BOPS  �Motivo da Alteracao                    �
�����������������������������������������������������������������������Ĵ
�            �          �       �                                       �
�������������������������������������������������������������������������/*/
/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �GetSrd  	    �Autor�Kelly Soares       � Data �11/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem as Informacoes do SRD de acordo com parametros para   �
�          �roteiro, periodo, numero de pagto e objeto.                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Retorno   �NIL                      									�
�����������������������������������������������������������������������Ĵ
�Uso	   �Generica      										    	�
�������������������������������������������������������������������������/*/
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
