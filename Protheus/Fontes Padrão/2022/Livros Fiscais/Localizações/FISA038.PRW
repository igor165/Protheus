#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FISA038.CH"

/*                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFISA038    บAutor  ณCamila Januแrio    บ Data ณ  22/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo de Certificado de Honorแrio                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChiGeraCertบAutor  ณCamila Januแrio    บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o Certificado dos Honorarios e atualiza SFE           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
		
		/*Se o perํodo , fornecedor at้ e loja at้ for em branco nใo existir, nใo deixo gerar o certificado*/		
		If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .OR. Empty(MV_PAR06) .OR. Empty(MV_PAR07) 
		 	MsgAlert(STR0046) //"Para a gera็ใo do certificado ้ necessแrio preencher os dados de perํodo e fornecedor/loja."
		 	Return
        Endif	
        
			cIniMes   := SubStr(MV_PAR01,1,2)
			cIniAno   := SubStr(MV_PAR01,3,6)
			cFinMes   := SubStr(MV_PAR02,1,2)
			cFinAno   := SubStr(MV_PAR02,3,6)
			aTaxas := TaxasSM2(Alltrim(MV_PAR03),cIniMes,cIniAno,cFinMes,cFinAno) 
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdฟ
	   		//ณBusco os honorarios com num de certificado dentro do periodo inicial e final e forn/lojaณ
	   		// Caso encontrado, este registro existente se tornarแ hist๓rico, para que seja feita nova
	   		// grava็ใo do registro mais atual da SFE
	  		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdู			
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
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAcumulo quando for o mesmo fornecedor do perํodoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
				
	
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
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAtualizo as variแveis com base nos acumuladores o sfe posicionadoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				nFatAtu := IIF(nFatAtu==1,0,nFatAtu)
				nVlAtua := nValBase*(1+(nFatAtu/100))
				nRetAtu := nRetenc*(1+(nFatAtu/100))
			
				If lNewCert
					cNroCert := ChiNroCert("RHO")				
				Endif
						
				lAcum   := .T.
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGera a reten็ใo acumulada ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
			                                                                                               
				Aadd(aDadSFE,{.F.,cNroCert,"","",cForn,cLoja,"RHO",0,0,0,"",nValBase,nVlAtua,nAliq,nFatAtu,nRetenc,nRetAtu,lAcum,cMesAno})
				GrvRetSFE(1,aDadSfe,.T.)
				aDadSFE := {}
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณZero as variแveis acumulativas e taxaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExistCrt   บAutor  ณCamila Januแrio     บ Data ณ  05/03/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa se jแ foi gerado ceritifcado para o perํodo       บฑฑ
ฑฑบ          ณ e fornecedor                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ExistCrt(cIniMes,cIniAno,cFinMes,cFinAno,cFornIni,cLojIni,cFornFim,cLojFim) 
Local lRet := .F. 
		
		If !MsgYesNo(STR0047) 
			lRet := .F.
		Else
			lRet := .T.
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdฟ
		//ณBusco os honorarios com num de certificado dentro do periodo inicial e final e forn/lojaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdู		
		If lRet
			DbSelectArea("SFE")                                               
			SFE->(DbSetOrder(3))		
				Do While SFE->(!Eof()) 
					If !Empty(SFE->FE_NROCERT) .And. SFE->FE_FORNECE >= cFornIni ;
						.And. SFE->FE_LOJA >= cLojIni .And. SFE->FE_FORNECE <= cFornFim ;
						.And. SFE->FE_LOJA <= cLojFim .And. SFE->FE_MESANO >= (cIniMes+cIniAno) ;
						.And. SFE->FE_MESANO <= (cFinMes+cFinAno)								
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					   		//ณCaso esteja sendo gerado um perํodo de um fornecedor no qual jแ existia gerado,
							// entใo atualiza o sfe gerado como um registro hist๓rico								
					   		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							RecLock("SFE",.F.)
							SFE->FE_REGHIST := "S"						
							SFE->(MsUnLock())																
					EndIf	
					SFE->(DbSkip())
				EndDo                                               
	     Endif
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChiExCert   บAutor  ณCamila Januแrio    บ Data ณ  23/09/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclui o Certificado dos Honorarios                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdฟ
		//ณBusco os honorarios com num de certificado dentro do periodo inicial e final e forn/lojaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤdู
		
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
		MsgAlert(cAlertaUPD) //"Para atualizar o dicionแrio de Perguntas SX1, atualizar o U_UPDFLOC"
		Return
	EndIf

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChiImpCert   บAutor  Camila Januแrio   บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o Certificado do Honorแrios                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
		MsgAlert(cAlertaUPD) //"Para atualizar o dicionแrio de Perguntas SX1, atualizar o U_UPDFLOC"
		Return
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCabec บAutor  ณCamila Januแrio      บ Data ณ  30/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime cabecalho do certificado de Honorario              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpDeclara บAutor  ณCamila Januแrio      บ Data ณ  30/09/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime texto de declaracao                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpTabela บAutor  ณCamila Januแrio      บ Data ณ   30/09/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime a tabela com os dados                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpRodape บAutor  ณCamila Januแrio       บ Data ณ  30/09/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime rodape da declaracao                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpDados บAutor  ณCamila Januแrio      บ Data ณ   30/09/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime a tabela com os dados                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se um mes nao tem dados, e alimento com valores de 0 e 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

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

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ฟ
	//ณImpressใo das linhas das movimentacoes dos mesesณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
        
	For n:= 1 to 12
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aAux[n][7],2),"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aAux[n][8],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7-90,AliDir(aAux[n][9],X3PICTURE("M2_MOEDA2")),opFont1)
 		oPrn:Say(nLin+nLin4,nCol6+=nCol7+90,AliDir(aAux[n][10],"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+nCol8,AliDir(Round(aAux[n][11],2),"@E 999,999,999"),opFont1) 	

	
		nCol6 := 250
		nLin  += nLin4		
	Next n  
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ฟ
		//ณImpressใo dos totais das movimentacoes dos mesesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aTot[1][1],2),"@E 999,999,999"),opFont1)
		oPrn:Say(nLin+nLin4,nCol6+=nCol7,AliDir(Round(aTot[1][2],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7-90,AliDir(Round(aTot[1][3],2),X3PICTURE("M2_MOEDA2")),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+90,AliDir(Round(aTot[1][4],2),"@E 999,999,999"),opFont1)	   	
		oPrn:Say(nLin+nLin4,nCol6+=nCol7+nCol8,AliDir(Round(aTot[1][5],2),"@E 999,999,999"),opFont1)
		   
Return
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraTMP   บAutor  ณCamila Januแrio     บ Data ณ  23/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o temporแrio com base na query                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraTMP()

Local cQuery := ""
Local cForn := "" 
Local aTot  := {}
Local nTot2:=nTot3:=nTot4:=nTot5:=nTot6:= 0
Private aDados := {}                                                                     

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤXฟ
		//ณGera arquivo temporแrio com os acumulados de SFE de acordo com os parametrosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤXู

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
				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona elementos no array de acordo com o mes de movimentacao para o mesmo fornecedorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			 			
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
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			   		//ณFaz a impressใo das movimentacoes do periodo anual , onde cada fornecedor tem uma pagina novaณ
		   	   		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTaxasSM2   บAutor  ณCamila Januแrio    บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca as taxas do SM2                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a primeira taxa do SM2 dos periodos selecionadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   


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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChiNroCertบAutor  ณCamila Januario     บ Data ณ  26/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca o numero do certificado                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Numero do certificado                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chile                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ChiNroCert(cImp)
Local cNum 		:= ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualizo o SX5 ou busco novo num de certificadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    AliDir()ณ Autor ณ Camila Januแrio ณ	      Data ณ04/10/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Fun็ใo que faz a impressใo dos registros					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ AliDir(nVlr,cPicture)	                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nVlr: valor a ser alinhado  cPicture: picture do valor     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cRet: valor alinhado a direita							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Rep. Dominicana	                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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