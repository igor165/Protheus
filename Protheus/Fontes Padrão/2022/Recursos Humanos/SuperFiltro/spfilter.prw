#INCLUDE "PROTHEUS.CH"

Static aGrupos	:= {} 
Static cUserId	:= "" 
Static __cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )

/*/
���������������������������������������������������������������������������������Ŀ
�Fun��o    � SPFILTER � Autor � Igor Franzoi                    � Data �09/03/2009�
���������������������������������������������������������������������������������Ĵ
�Descri��o �Fonte criado para armazenar as funcoes de SuperFiltro                 �
���������������������������������������������������������������������������������Ĵ
�Sintaxe   �                                                                      �
���������������������������������������������������������������������������������Ĵ
�Uso       � Generico                                                             �
���������������������������������������������������������������������������������Ĵ
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                     �
���������������������������������������������������������������������������������Ĵ
�Programador      � Data   � BOPS/FNC  �  Motivo da Alteracao                     �
���������������������������������������������������������������������������������Ĵ
�Cecilia C.       �04/08/14�TQFZO4     �Incluido o fonte da 11 para a 12.         �
�����������������������������������������������������������������������������������/*/


/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SRVSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SRV									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SRV				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/ 
Function SRVSPFilter()
  	If __cORGSPFL # 'S'
		Return ""
	Endif
Return GetGPEXSpFl("SRV", "RV")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SRYSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SRY									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SRY				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SRYSPFilter() 
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRY", "RY")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �CTTSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela CTT									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela CTT				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function CTTSPFilter()
	If (__cORGSPFL # 'S') .OR. (!(cModulo $ ("APD","CSA","GPE","PON","RSP","TRM","APT","RPM")))  //superfiltro CTT s� aplicado sobre modulos de RH
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RCHSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RCH									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RCH				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RCHSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCH", "RCH")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RCJSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RCJ									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RCJ				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RCJSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCJ", "RCJ")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SRCSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SRC									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SRC				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SRCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRC", "RC")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SRDSPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SRD									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SRD				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SRDSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRD", "RD")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SI3SPFilter	 � Autor �Igor Franzoi		   � Data �09/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SI3									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SI3				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SI3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RGBSPFilter	 � Autor �Igor Franzoi		   � Data �20/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RGB									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RGB				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RGBSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGB", "RGB")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RCOSPFilter	 � Autor �Igor Franzoi		   � Data �20/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RCO									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RCO				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RCOSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCO", "RCO")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RGCSPFilter	 � Autor �Igor Franzoi		   � Data �20/03/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RGC									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RGC				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RGCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGC", "RGC")

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RCPSPFilter	 � Autor �Valdeci Lira		   � Data �14/05/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela Rcp									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela Rcp				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RCPSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCP", "RCP")
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RCQSPFilter	 � Autor �Valdeci Lira		   � Data �14/05/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RCQ									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela Rcp				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RCQSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCQ", "RCQ")
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SR3SPFilter	 � Autor �Valdeci Lira		   � Data �14/05/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SR3									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SR3				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SR3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR3", "R3")
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SR7SPFilter	 � Autor �Valdeci Lira		   � Data �14/05/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela SR7									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela SR7				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function SR7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR7", "R7")
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RG7SPFilter	 � Autor �Valdeci Lira		   � Data �14/05/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �SuperFiltro da Tabela RG7									 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �cExp = Expressao de filtro para a tabela RG7				 �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �Generico													 �
��������������������������������������������������������������������������/*/
Function RG7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RG7", "RG7")
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SPFILTER  �Autor  �Microsiga           � Data �  04/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	   		
		/*��������������������������������������������������Ŀ
		  �Procura todas as restricoes que cabem ao usuario, �
		  �considera os grupos e restricao pertencentes a ele�
		  ����������������������������������������������������*/	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SPFILTER  �Autor  �Microsiga           � Data �  04/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	�������������������������������������������������������������Ŀ
	� Caso a expressao de filtro seja maior que 4000 caracteres   �
	� imprime o tamanho no server								  �	
	���������������������������������������������������������������/*/	
	If ( Len(cExp) > 4000 )
		ConOut("Tamanho: " + Str(Len(cExp)))
	EndIf
		
Return cExp
