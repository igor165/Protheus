#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FISA038.CH"

/*                    
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISA038    �Autor  �Camila Janu�rio    � Data �  22/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera��o de Certificado de Honor�rio                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA038()

Local cAlias := "SFE"
Local aCores := {}
Local cFiltra := "FE_NROCERT <> '' .AND. FE_REGHIST <> 'S'"
Private cAlertaUPD := STR0001+STR0002

Private cCadastro := STR0003 
Private aRotina := {}  

Private aIndexsfe := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSFE,@cFiltra)}

AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})  
AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Gerar" ,"ChiCertSFE",0,3})
AADD(aRotina,{"Excluir" ,"ChiExCert",0,4})
AADD(aRotina,{"Imprimir" ,"ChiImpCert",0,5})

Eval(bFiltraBrw)
dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(6,1,22,75,cAlias)    

EndFilBrw(cAlias,aIndexSFE) 

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChiGeraCert�Autor  �Camila Janu�rio    � Data �  23/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o Certificado dos Honorarios e atualiza SFE           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                           
Function ChiCertSFE()

Local cPerg 	:= "FIS038A"
Local cQueryFE 	:= ""
Local cIniMes   := ""
Local cIniAno   := ""
Local cFinMes   := ""
Local cFinAno   := ""
Local cForn		:= ""
Local aTaxas	:= {}
Local nI        := 0
Local cEmis     := ""
Local cMesAno   := ""
Local nFatAtu   := 0
Local nValBase  := 0
Local nVlAtua   := 0
Local nRetenc   := 0
Local nRetAtu   := 0
Local aDadSfe   := {}
Local lAcum     := .F.
Local cNroCert  := ""
Local lNewCert  := .T.

DbSelectArea("SX1")
DbSetOrder(1)

	If Dbseek(cPerg)

		If !Pergunte(cPerg,.T.)
			Return
		Endif 
		
		/*Se o per�odo , fornecedor at� e loja at� for em branco n�o existir, n�o deixo gerar o certificado*/		
		If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. Empty(MV_PAR06) .OR. Empty(MV_PAR07) 
		 	MsgAlert(STR0046) //"Para a gera��o do certificado � necess�rio preencher os dados de per�odo e fornecedor/loja."
		 	Return
        Endif	
        
			cIniMes   := SubStr(MV_PAR01,1,2)
			cIniAno   := SubStr(MV_PAR01,3,6)
			cFinMes   := SubStr(MV_PAR02,1,2)
			cFinAno   := SubStr(MV_PAR02,3,6)
			aTaxas := TaxasSM2(Alltrim(MV_PAR03),cIniMes,cIniAno,cFinMes,cFinAno) 
			
			//�����������������������������������������������������������������������������������������d�
	   		//�Busco os honorarios com num de certificado dentro do periodo inicial e final e forn/loja�
	   		// Caso encontrado, este registro existente se tornar� hist�rico, para que seja feita nova
	   		// grava��o do registro mais atual da SFE
	  		//�����������������������������������������������������������������������������������������d�			
			If !ExistCrt(cIniMes,cIniAno,cFinMes,cFinAno,mv_par04,mv_par05,mv_par06,mv_par07) 
				Return
			Endif
			
			cQueryFE += "SELECT DISTINCT SFE.* "
			cQueryFE += "FROM "+RetSqlName("SFE")+ " SFE "
			cQueryFE += "WHERE FE_EMISSAO >= '"+(cIniAno+cIniMes+"01")+"' "
			cQueryFE += "AND FE_EMISSAO <= '"+(cFinAno+cFinMes+"31")+"' "
			cQueryFE += "AND FE_ACUM = '' "
			cQueryFE += "AND FE_NROCERT = '' "
			cQueryFE += "AND FE_REGHIST = '' "				
			cQueryFE += "AND FE_FORNECE BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
			cQueryFE += "AND FE_LOJA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR07+"' "
			cQueryFE += "AND SFE.D_E_L_E_T_ = '' "
			cQueryFE += "ORDER BY FE_FORNECE, FE_EMISSAO"	
	
			
		  	If Select("QUERYSFE")>0
				DbSelectArea("QUERYSFE")
				QUERYSFE->(DbCloseArea())
			Endif
							                              
			TcQuery cQueryFE New Alias "QUERYSFE"	
					
			DbSelectArea("QUERYSFE")
			Do While QUERYSFE->(!Eof())
			
				If  Empty(cNroCert)            		
					lNewCert := .T.					
				Else
					if  cForn <> QUERYSFE->FE_FORNECE 
		       	    	lNewCert := .T.
					Else
						lNewCert := .F.
					Endif					
				Endif      			
				 			
				cForn := QUERYSFE->FE_FORNECE                            
				cEmis := Substr(QUERYSFE->FE_EMISSAO,1,6)			
	
				//������������������������������������������������Ŀ
				//�Acumulo quando for o mesmo fornecedor do per�odo�
				//�������������������������������������������������� 
				
	
				Do While (QUERYSFE->FE_FORNECE == cForn .AND. Substr(QUERYSFE->FE_EMISSAO,1,6) == cEmis)						
				
					For nI := 1 to Len(aTaxas)
						If nFatAtu == 0 											
							If (Substr(aTaxas[nI][1],1,2) == Substr(QUERYSFE->FE_EMISSAO,5,2)) .AND. Substr(aTaxas[nI][1],3,4) == Substr(QUERYSFE->FE_EMISSAO,1,4) 
								nFatAtu := aTaxas[nI][2]					
							EndIf	
						EndIf
					Next nI			
					nValBase += QUERYSFE->FE_VALBASE
	            	nRetenc += QUERYSFE->FE_RETENC
	            	cMesAno := Substr(QUERYSFE->FE_EMISSAO,5,2)+Substr(QUERYSFE->FE_EMISSAO,1,4)
	           		nAliq   := QUERYSFE->FE_ALIQ
	            	
	           		cEmis := Substr(QUERYSFE->FE_EMISSAO,1,6)
					cForn := QUERYSFE->FE_FORNECE
					cLoja := QUERYSFE->FE_LOJA 											
					
	           		QUERYSFE->(DbSkip()) 		
	           			
					
				EndDo		
	
				//�����������������������������������������������������������������Ŀ
				//�Atualizo as vari�veis com base nos acumuladores o sfe posicionado�
				//�������������������������������������������������������������������
				
				nFatAtu := IIF(nFatAtu==1,0,nFatAtu)
				nVlAtua := nValBase*(1+(nFatAtu/100))
				nRetAtu := nRetenc*(1+(nFatAtu/100))
			
				If lNewCert
					cNroCert := ChiNroCert("RHO")				
				Endif
						
				lAcum   := .T.
	
				//��������������������������Ŀ
				//�Gera a reten��o acumulada �
				//����������������������������	
			                                                                                               
				Aadd(aDadSFE,{.F.,cNroCert,"","",cForn,cLoja,"RHO",0,0,0,"",nValBase,nVlAtua,nAliq,nFatAtu,nRetenc,nRetAtu,lAcum,cMesAno})
				GrvRetSFE(1,aDadSfe,.T.)
				aDadSFE := {}
	
				//�������������������������������������Ŀ
				//�Zero as vari�veis acumulativas e taxa�
				//���������������������������������������
	
				nVlAtua  := 0 		
				nRetAtua := 0
				nFatAtu  := 0
				nAliq    := 0
				nValBase := 0
				nRetenc  := 0
				
			Enddo				
	Else 
		MsgAlert(cAlertaUPD) 
		Return
	Endif
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExistCrt   �Autor  �Camila Janu�rio     � Data �  05/03/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa se j� foi gerado ceritifcado para o per�odo       ���
���          � e fornecedor                                               ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ExistCrt(cIniMes,cIniAno,cFinMes,cFinAno,cFornIni,cLojIni,cFornFim,cLojFim) 
Local lRet := .F. 
		
		If !MsgYesNo(STR0047) 
			lRet := .F.
		Else
			lRet := .T.
		Endif
		//�����������������������������������������������������������������������������������������d�
		//�Busco os honorarios com num de certificado dentro do periodo inicial e final e forn/loja�
		//�����������������������������������������������������������������������������������������d�		
		If lRet
			DbSelectArea("SFE")                                               
			SFE->(DbSetOrder(3))		
				Do While SFE->(!Eof()) 
					If !Empty(SFE->FE_NROCERT) .And. SFE->FE_FORNECE >= cFornIni ;
						.And. SFE->FE_LOJA >= cLojIni .And. SFE->FE_FORNECE <= cFornFim ;
						.And. SFE->FE_LOJA <= cLojFim .And. SFE->FE_MESANO >= (cIniMes+cIniAno) ;
						.And. SFE->FE_MESANO <= (cFinMes+cFinAno)								
							//��������������������������������������������������������������������������������Ŀ
					   		//�Caso esteja sendo gerado um per�odo de um fornecedor no qual j� existia gerado,
							// ent�o atualiza o sfe gerado como um registro hist�rico								
					   		//����������������������������������������������������������������������������������
							RecLock("SFE",.F.)
							SFE->FE_REGHIST := "S"						
							SFE->(MsUnLock())																
					EndIf	
					SFE->(DbSkip())
				EndDo                                               
	     Endif
Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChiExCert   �Autor  �Camila Janu�rio    � Data �  23/09/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclui o Certificado dos Honorarios                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ChiExCert()

Local cPerg 	:= "FIS038B"
Local cIniMes   := ""
Local cIniAno   := ""
Local cFinMes   := ""
Local cFinAno   := ""

DbSelectArea("SX1")
DbSetOrder(1)

	If Dbseek(cPerg)
	
		If !Pergunte(cPerg,.T.)           
			Return
		EndIf		
		
		cIniMes   := SubStr(MV_PAR01,1,2)
		cIniAno   := SubStr(MV_PAR01,3,6)
		cFinMes   := SubStr(MV_PAR02,1,2)
		cFinAno   := SubStr(MV_PAR02,3,6)		

		//�����������������������������������������������������������������������������������������d�
		//�Busco os honorarios com num de certificado dentro do periodo inicial e final e forn/loja�
		//�����������������������������������������������������������������������������������������d�
		
		DbSelectArea("SFE")                                               
		SFE->(DbSetOrder(3))		
			Do While SFE->(!Eof()) 
				If !Empty(SFE->FE_NROCERT) .And. Empty(SFE->FE_REGHIST) .And. SFE->FE_FORNECE >= MV_PAR03 ;
					.And. SFE->FE_LOJA >= MV_PAR04 .And. SFE->FE_FORNECE <= MV_PAR05 ;
					.And. SFE->FE_LOJA <= MV_PAR06 .And. SFE->FE_MESANO >= (cIniMes+cIniAno) ;
					.And. SFE->FE_MESANO <= (cFinMes+cFinAno) 
													
						RecLock("SFE",.F.) 
						Dbdelete()
						SFE->(MsUnLock())							
				EndIf	
				SFE->(DbSkip())
			EndDo  				
	Else
		MsgAlert(cAlertaUPD) //"Para atualizar o dicion�rio de Perguntas SX1, atualizar o U_UPDFLOC"
		Return
	EndIf

Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChiImpCert   �Autor  Camila Janu�rio   � Data �  23/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime o Certificado do Honor�rios                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ChiImpCert()
 
Local cPerg := "FIS038C" 
Private clTitulo 	:= STR0004 
Private opFont1		:= TFont():New("Verdana",,9,,,,,,,) 
Private opFont2  	:= TFont():New("Verdana",,14,.T.,,,,,,.F.) 

Bold := opFont2:Bold


DbSelectArea("SX1")
DbSetOrder(1)

	If Dbseek(cPerg)
		
		If !Pergunte(cPerg,.T.)           
			Return
		EndIf	
		
		oPrn := TmsPrinter():New(clTitulo)
		oPrn:SetPaperSize(9)
		oPrn:SetPortrait()		
		GeraTMP()
	
	Else
		MsgAlert(cAlertaUPD) //"Para atualizar o dicion�rio de Perguntas SX1, atualizar o U_UPDFLOC"
		Return
	EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCabec �Autor  �Camila Janu�rio      � Data �  30/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime cabecalho do certificado de Honorario              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpCabec() 

Local nLin     := 100
Local nCol 	   := 200
Local nLin2    := 40

	oPrn:Say(nLin,nCol,STR0005+SPACE(2)+SM0->M0_NOME,opFont1)
	oPrn:Say(nLin+=nLin2,nCol,STR0006+SPACE(2)+SM0->M0_CGC,opFont1)  
	oPrn:Say(nLin+=nLin2,nCol,STR0007+SPACE(2)+SM0->M0_ENDCOB,opFont1)
	oPrn:Say(nLin+=nLin2,nCol,STR0008+SPACE(2)+MV_PAR08,opFont1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpDeclara �Autor  �Camila Janu�rio      � Data �  30/09/11 ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime texto de declaracao                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpDeclara(cNomFor,cCGC,cArtHon,cCert) 

Local nLin  := 300 
Local nCol  := 200
Local nLin2 := 40  
Local nCol2 := 500
Local nCol3 := 1200

If cArtHon == "1"
	cArthon := "Art.42"
Else
	cArthon := "Art.48"
EndIf
	 	
	oPrn:Say(nLin,nCol+nCol2+150,STR0009,opFont2)
	oPrn:Say(nLin+=nLin2+100,nCol+nCol3,STR0010+SPACE(3)+cCert,opFont1)
	oPrn:Say(nLin+=nLin2,nCol+nCol3,STR0011+SM0->M0_CIDENT+","+DTOC(ddatabase),opFont1)
	oPrn:Say(nLin+=nLin2+40,nCol,STR0012+Space(3)+SM0->M0_NOMECOM+Space(3)+STR0013+SPACE(3),opFont1)
	oPrn:Say(nLin+=nLin2,nCol,cNomFor+SPACE(3)+STR0014+Space(3)+cCGC+STR0015+Space(3)+MV_PAR01+Space(3)+STR0016,opFont1)
	oPrn:Say(nLin+=nLin2,nCol,STR0017+Space(3)+cArtHon+STR0018,opFont1)	 	
	oPrn:Say(nLin+=nLin2,nCol,STR0019,opFont1)	

Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTabela �Autor  �Camila Janu�rio      � Data �   30/09/11 ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime a tabela com os dados                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpTabela() 

Local nLin  := 700 //600
Local nCol  := 200
Local nLin2 := 40
Local nCol2 := 2200
Local nCol3 := 150  //167
Local nLin3 := 1955 //1852
Local nLin4 := 20
Local nCol4 := 11
Local nLin5 := 60
Local nCol6 := 200
Local nCol7 := 300
Local nLin6 := 50

	oPrn:Line(nLin,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol6+nCol4,STR0020,opFont1)
	oPrn:Say(nLin+nLin4+nLin5,nCol6+nCol4,"(1)",opFont1)
	
	nCol6+=nCol4
	
	oPrn:Say(nLin+nLin4,nCol6+=nCol7,STR0021,opFont1)
	oPrn:Say(nLin+nLin4+nLin5,nCol6,"(2)",opFont1)						

	
	oPrn:Say(nLin+nLin4,nCol6+=nCol7,STR0022,opFont1)
	oPrn:Say(nLin+nLin4+40,nCol6,STR0023,opFont1)	
	oPrn:Say(nLin+nLin4+nLin5+30,nCol6,"(3)",opFont1)						
	
	oPrn:Say(nLin+nLin4,nCol6+=nCol7,STR0024,opFont1)
	oPrn:Say(nLin+nLin4+40,nCol6,STR0025,opFont1)	
	oPrn:Say(nLin+nLin4+nLin5+30,nCol6,"(4)",opFont1)						
	
	oPrn:Say(nLin+nLin4+nLin6,nCol6+=nCol7,STR0026,opFont1)
	oPrn:Say(nLin+nLin4+nLin5+nLin6,nCol6,"(5)",opFont1)
	
	oPrn:Say(nLin+nLin4+nLin6,nCol6+=nCol7,STR0027,opFont1)
	oPrn:Say(nLin+nLin4+nLin5+nLin6,nCol6,"(6)",opFont1)
	
	oPrn:Say(nLin+nLin4+nLin6-50,nCol6-50,STR0028,opFont1)	
		
	oPrn:Line(nLin+60,nCol+1200,nLin+60,nCol2)
	
	oPrn:Line(nLin+=nLin2+100,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0029),opFont1)			
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0030),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0031),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)       
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0032),opFont1)		
		
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0033),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0034),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0035),opFont1)			
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0036),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0037),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0038),opFont1)		

	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0039),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0040),opFont1)		
	
	oPrn:Line(nLin+=nLin2,nCol,nLin+=nLin2,nCol2)
	oPrn:Say(nLin+nLin4,nCol+nCol4,Upper(STR0041),opFont1)
		
	oPrn:Line(nLin+=nLin2-3,nCol,nLin+=nLin2,nCol2)
	
	nLin  := 739
	nCol  := 200 

	oPrn:Line(nLin,nCol,nLin3,nCol)
	oPrn:Line(nLin,nCol+=nCol3,nLin3,nCol+=nCol3)
	oPrn:Line(nLin,nCol+=nCol3,nLin3,nCol+=nCol3)
	oPrn:Line(nLin,nCol+=nCol3,nLin3,nCol+=nCol3)
	oPrn:Line(nLin,nCol+=nCol3,nLin3,nCol+=nCol3)
	oPrn:Line(nLin+70,nCol+=nCol3,nLin3,nCol+=nCol3)
	oPrn:Line(nLin,nCol+=nCol3,nLin3,nCol+=nCol3+199)	

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpRodape �Autor  �Camila Janu�rio       � Data �  30/09/11 ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime rodape da declaracao                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpRodape() 

Local nLin  := 2100
Local nCol  := 200
Local nLin2 := 40
Local nCol2 := 1300

	
	oPrn:Say(nLin,nCol,STR0042;
	+ STR0043,opFont1) 
	oPrn:Say(nLin+=nLin2,nCol,STR0044;
	+ STR0045,opFont1)
		
	oPrn:Line(nLin+200,nCol2,nLin+200,nCol2+800)
	oPrn:Say(nLin+300,nCol2-200,SM0->M0_NOMECOM+Space(10)+","+SM0->M0_CGC,opFont1)
	

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpDados �Autor  �Camila Janu�rio      � Data �   30/09/11 ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprime a tabela com os dados                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpDados(aDados,aTot) 

Local nLin  := 870 
Local nLin4 := 80
Local nCol6 := 250 
Local nCol7 := 300
Local nCol8 := 145

Local n     := 0 
Local ni    := 1
Local nj 	:= 1 
Local aAux  := {}
  
//�����������������������������������������������������������������Ŀ
//�Verifico se um mes nao tem dados, e alimento com valores de 0 e 1�
//�������������������������������������������������������������������

Do While (Len(aAux) < 12)			 
	If Len(aDados) >= nJ
		If  Alltrim(Str(nI)) <> aDados[nJ][6]
				aadd(aAux,{aDados[nJ][1],aDados[nj][2],aDados[nj][3],aDados[nj][4],aDados[nj][5],Alltrim(Str(nI)),0,0,0,0,0}) 					
		Else
			aadd(aAux,aDados[nJ])
			nJ++
		EndIf	
		nI++
	Else
		Do While (Len(aAux)<12)
				aadd(aAux,{aDados[nJ-1][1],aDados[nj-1][2],aDados[nj-1][3],aDados[nj-1][4],aDados[nj-1][5],Alltrim(Str(nI)),0,0,0,0,0})
				nI++			
		End do
	EndIf
EndDo

	//�������������������������������������������������<�
	//�Impress�o das linhas das movimentacoes dos meses�
	//�������������������������������������������������<�
        
	For n:= 1 to 12
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aAux[n][7],2),"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aAux[n][8],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7-90,AliDir(aAux[n][9],X3PICTURE("M2_MOEDA2")),opFont1)
 		oPrn:Say(nLin+nLin4,nCol6+=nCol7+90,AliDir(aAux[n][10],"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+nCol8,AliDir(Round(aAux[n][11],2),"@E 999,999,999"),opFont1) 	

	
		nCol6 := 250
		nLin  += nLin4		
	Next n  
	
		//�������������������������������������������������<�
		//�Impress�o dos totais das movimentacoes dos meses�
		//�������������������������������������������������<�
	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aTot[1][1],2),"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aTot[1][2],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7-90,AliDir(Round(aTot[1][3],2),X3PICTURE("M2_MOEDA2")),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+90,AliDir(Round(aTot[1][4],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+nCol8,AliDir(Round(aTot[1][5],2),"@E 999,999,999"),opFont1)
		   
Return
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraTMP   �Autor  �Camila Janu�rio     � Data �  23/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o tempor�rio com base na query                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraTMP()

Local cQuery := ""
Local cForn := "" 
Local aTot  := {}
Local nTot2:=nTot3:=nTot4:=nTot5:=nTot6:= 0
Private aDados := {}                                                                     

		//�����������������������������������������������������������������������������X�
		//�Gera arquivo tempor�rio com os acumulados de SFE de acordo com os parametros�
		//�����������������������������������������������������������������������������X�

		cQuery += "SELECT DISTINCT SFE.*, SA2.* "
		cQuery += "FROM "+RetSqlName("SFE")+ " SFE "
		cQuery += "LEFT JOIN "+RetSqlName("SA2")+ " SA2 ON "
	  	cQuery += "A2_COD = FE_FORNECE "
   		cQuery += "AND A2_LOJA = FE_LOJA "
   		cQuery += "AND A2_FILIAL = '"+xFilial("SA2")+"' "
   		cQuery += "AND SA2.D_E_L_E_T_ = '' "   		
		cQuery += "WHERE FE_MESANO LIKE '__"+mv_par01+"%' "   		
		cQuery += "AND FE_FORNECE BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' "
		cQuery += "AND FE_LOJA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
		cQuery += "AND FE_ACUM = '1' "		
		cQuery += "AND FE_NROCERT <> '' "
		cQuery += "AND FE_REGHIST <> 'S' "		
		cQuery += "AND SFE.D_E_L_E_T_ = '' "				
		cQuery += "ORDER BY FE_FORNECE, FE_EMISSAO"  	
		
	  	If Select("TMP")>0
			DbSelectArea("TMP")
			TMP->(DbCloseArea())
		Endif
						                              
		TcQuery cQuery New Alias "TMP"	
				
		DbSelectArea("TMP")
		Do While TMP->(!Eof())
			cForn := TMP->FE_FORNECE
			cMes  := Substr(TMP->FE_MESANO,1,2)
				
		//���������������������������������������������������������������������������������������Ŀ
		//�Adiciona elementos no array de acordo com o mes de movimentacao para o mesmo fornecedor�
		//�����������������������������������������������������������������������������������������

			 			
			Do While (TMP->FE_FORNECE == cForn) 
				aadd(aDados,{TMP->A2_COD, ;
							 TMP->A2_LOJA, ;
							 TMP->A2_NOME, ;
							 TMP->A2_CGC, ;
							 TMP->A2_ARTHON, ;
							 Alltrim(Str(val(Substr(TMP->FE_MESANO,1,2)))),; 
							 TMP->FE_VALBASE, ;
							 TMP->FE_RETENC, ;
							 TMP->FE_FATATU, ;
							 TMP->FE_VLATUA, ;
							 TMP->FE_RETATU, ;
							 TMP->FE_NROCERT})
							 
							 nTot2 += TMP->FE_VALBASE
							 nTot3 += TMP->FE_RETENC
							 nTot4 := 0
							 nTot5 += TMP->FE_VLATUA
							 nTot6 += TMP->FE_RETATU				 
							 						
						 
				TMP->(DbSkip())
				If TMP->FE_FORNECE <> cForn		
				
					//���������������������������������������������������������������������������������������������Ŀ
			   		//�Faz a impress�o das movimentacoes do periodo anual , onde cada fornecedor tem uma pagina nova�
		   	   		//�����������������������������������������������������������������������������������������������
				
					oPrn:StartPage()
					ImpCabec()
			 		ImpDeclara(aDados[1][3],aDados[1][4],aDados[1][5],aDados[1][12])
					ImpTabela()
			  		ImpRodape()       
			  		
			   		aadd(aTot,{nTot2,nTot3,nTot4,nTot5,nTot6})
			    	ImpDados(aDados,aTot)
			    	
			    	oPrn:EndPage()					
					aTot := {}										
					aDados := {}							 
                EndIf								
			EndDo
		
		EndDo

 oPrn:Preview()
 oPrn:End()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TaxasSM2   �Autor  �Camila Janu�rio    � Data �  26/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca as taxas do SM2                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TaxasSM2(cMoeda,cIniMes,cIniAno,cFinMes,cFinAno)

Local aTax	  := {}
Local cMesAno := ""
Local nTx     := 1
Local cFiltro := ""
Local n 	  := 1
Local lChegou := .F.

DbSelectArea("SM2")
DbSetOrder(1)
DbGoTop()

//���������������������������������������������������������Ŀ
//�Verifica a primeira taxa do SM2 dos periodos selecionados�
//�����������������������������������������������������������   


Do While SM2->(!Eof())
	If !lChegou
		Do While !dbSeek(ctod(STRZERO(n,2)+"/"+cIniMes+"/"+cIniAno))
			n++
		   	SM2->(DbSkip())	
		EndDo
		lChegou := .T.		
	Endif	
	
	If (((Substr(DTOC(SM2->M2_DATA),4,2)$cIniMes) .OR. (Substr(DTOC(SM2->M2_DATA),7,4)$cIniAno)) .OR. ;
	   ((Substr(DTOC(SM2->M2_DATA),4,2)$cFinMes) .OR. (Substr(DTOC(SM2->M2_DATA),7,4)$cFinAno)))
	   
		cMesAno := Substr(DTOC(SM2->M2_DATA),4,2)+Substr(DTOC(SM2->M2_DATA),7,4)
		nTx := IIf (&("SM2->M2_MOEDA"+cMoeda)==0,1,&("SM2->M2_MOEDA"+cMoeda))
		aadd(aTax,{cMesAno,nTx})
	EndIf

	SM2->(DbSkip())		
End Do

Return aTax


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChiNroCert�Autor  �Camila Januario     � Data �  26/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o numero do certificado                              ���
�������������������������������������������������������������������������͹��
���Retorno   � Numero do certificado                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Chile                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ChiNroCert(cImp)
Local cNum 		:= ""

	//�����������������������������������������������Ŀ
	//�Atualizo o SX5 ou busco novo num de certificado�
	//�������������������������������������������������  
		DbSelectArea("SX5")

		If dbSeek(xFilial("SX5")+"99"+cImp)
			cNum := (X5Descri())
			cNum := Alltrim(StrZero(VAL(cNum)+1,TamSx3("FE_NROCERT")[1]- Len(cImp)))
			If RecLock("SX5",.F.)
				Replace X5_DESCRI	WITH cNum
				Replace X5_DESCSPA	WITH cNum
				Replace X5_DESCENG	WITH cNum
				SX5->(MsUnLock())
			EndIf
		Else
			RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '99'
				SX5->X5_FILIAL 	:= xFilial("SX5")     
				SX5->X5_CHAVE  	:= cImp
				SX5->X5_DESCRI 	:= '00000001'
				SX5->X5_DESCSPA := '00000001'
				SX5->X5_DESCENG := '00000001'
				cNum         	:= '00000001'
			MsUnLock()
   		EndIf
   		
Return cNum

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    AliDir()� Autor � Camila Janu�rio �	      Data �04/10/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o que faz a impress�o dos registros					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AliDir(nVlr,cPicture)	                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nVlr: valor a ser alinhado  cPicture: picture do valor     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRet: valor alinhado a direita							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Rep. Dominicana	                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AliDir(nVlr,cPicture)
	Local cRet:=""
	
	If Len(Alltrim(Str(Int(nVlr))))==9                    
		cRet:=PADL(" ",1," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==8                    
		cRet:=PADL(" ",3," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==7                    
		cRet:=PADL(" ",5," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==6                    
		cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==5                     
		cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==4                       
		cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==3                    
		cRet:=PADL(" ",15," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==2               
		cRet:=PADL(" ",17," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
		cRet:=PADL(" ",19," ")+alltrim(Transform(nVlr,cPicture))
	Endif 
Return cRet