#INCLUDE "PROTHEUS.CH"
/*/
��������������������������������������������������������������������������Ŀ
�Fun��o    �RD0SPFilter  � Autor �Rogerio Ribeiro      � Data �//          �
��������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RD0                                      �
��������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>                                      �
��������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>                                      �
��������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RD0                   �
��������������������������������������������������������������������������Ĵ
�Observa��o�                                                               �
��������������������������������������������������������������������������Ĵ
� Uso      �Generico                                                       �
��������������������������������������������������������������������������Ĵ
�             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.            �
��������������������������������������������������������������������������Ĵ
�Programador � Data     � BOPS/FNC       �Motivo da Alteracao              �
��������������������������������������������������������������������������Ĵ
�Cecilia C.  �04/08/2014�TQFZO4          �Incluido o fonte da 11 para a 12.�
����������������������������������������������������������������������������/*/
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
