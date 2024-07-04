#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOCPAR.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณLocPar    บ Autor ณ Marcos Kato        บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Montagem das informacoes arquivo magentico           	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑบLuis Enrํquez  28/12/2016  SERINN001-419 -Se realiz๓ merge  contra     บฑฑ
ฑฑบ                                          Inova็ใo 12.1.15 ctree       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOCPAR(cTipo,cDtIni,cDtFim,aParam)
	Local cQryNLvro:="", cQryLvro :=""
	Local cTRBNLvro:="", cTRBLvro :=""
	Local cTpNf    :="", cLivr    :="" 
	Local nCont    :=0 ,nBasI05  :=0 , nVlrI05  :=0 , nBasI10  :=0 , nVlrI10  :=0 , nVlrExe  :=0 , nVlrIng  :=0 
	Local nQtdReg  :=0 ,nTVlrExe :=0,ntVlrIng :=0
	Local aNrLvro  :={}
	Local aLogReg  :={} 
	Local aLogRel  :={}    
	Local nBase10:= 0
	Local nBase05:= 0
	Local nVl10:= 0
	Local nVl05:= 0
	Local nExenta:= 0
	Private lAutomato:= isblind()
	Private oTmpTable1 //leem
	Private oTmpTable2 //leem

	If cTipo=="VEN"             
		Aadd(aLogRel,STR0001)                      // "Relatorio Livro de Vendas"(Cabec1)			
		Aadd(aLogRel,"")				           //Cabec2
		Aadd(aLogRel,"G")				           //Tamanho relatorio

		Aadd(aLogRel,PADR(STR0003,20)+PADR(STR0004,5)+PADR(STR0005,30)+PADR(STR0008,10)+PADR(STR0009,22)+PADR(STR0010,15)+;
		PAD(STR0011,20)+PAD(STR0012,20)+PAD(STR0013,20)+PAD(STR0014,20)+PAD(STR0015,20)+PAD(STR0016,20))
		//"RUC","DV","Cliente","Tipo de Documento","Numero do Documento","Emissao","Base 10%","Valor 10%","Base 5%","Valor 5%","Exenta","Valor"
	Else
		Aadd(aLogRel,STR0002)                      //"Relatorio Livro de Compras"(Cabec1)			
		Aadd(aLogRel,"")				           //Cabec2
		Aadd(aLogRel,"G")				           //Tamanho relatorio
		Aadd(aLogRel,PADR(STR0003,20)+PADR(STR0004,5)+PADR(STR0006,30)+PADR(STR0008,10)+PADR(STR0009,22)+PADR(STR0010,15)+;
		PAD(STR0011,20)+PAD(STR0012,20)+PAD(STR0013,20)+PAD(STR0014,20)+PAD(STR0015,20))
		//"RUC","DV","Fornecedor","Numero Timbrado","Tipo de Documento","Numero do Documento","Emissao","Base 10%","Valor 10%","Base 5%","Valor 5%","Exenta"
	Endif	
	Aadd(aLogreg,STR0017)//"Relatorio Log de Importacao"(Cabec1)			
	Aadd(aLogreg,"")				           //Cabec2    
	Aadd(aLogreg,"P")				           //Tamanho Relatorio
	Aadd(aLogreg,Replicate("-",80))	
	Aadd(aLogreg,STR0018)//"Parametros"	
	Aadd(aLogreg,Replicate("=",80))	
	Aadd(aLogreg,STR0019+Substr(cDtIni,7,4)+"/"+Substr(cDtIni,5,2)+"/"+Substr(cDtIni,1,4))//"Data Inicial          :"	
	Aadd(aLogreg,STR0020+Substr(cDtFim,7,4)+"/"+Substr(cDtFim,5,2)+"/"+Substr(cDtFim,1,4))//"Data Final            :"
	Aadd(aLogreg,Replicate("-",80))	            
	Aadd(aLogreg,Iif(cTipo=="VEN",STR0021,STR0022))//"Livro de Venda ou Livro de Compra"	
	Aadd(aLogreg,Replicate("=",80))	

	LocTrbs(cTipo)  

	If Substr(cDtIni,1,6)==Substr(cDtFim,1,6) .and.  Len(aParam) > 0

		cQryNLvro:=" SELECT DISTINCT FC_TES TES , FB_CPOLVRO NLIVRO " 
		cQryNLvro+=" FROM "+RetsqlName("SFC")+" SFC "
		cQryNLvro+=" INNER JOIN "+RetsqlName("SFB")+" SFB ON "
		cQryNLvro+=" FC_IMPOSTO=FB_CODIGO "
		cQryNLvro+=" AND SUBSTRING(FB_CODIGO,1,2) = 'IV' "
		cQryNLvro+=" AND SFC.D_E_L_E_T_='' "
		cQryNLvro+=" WHERE SFB.D_E_L_E_T_='' "
		cQryNLvro+=" ORDER BY FC_TES "

		If Select("TRBLVRO")>0
			DbSelectArea("TRBLVRO")	
			TRBLVRO->(DbCloseArea())
		Endif

		cTRBNLVRO := ChangeQuery(cQryNLvro)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBNLVRO ) ,"TRBNLVRO", .T., .F.)

		aNrLvro:={}
		DbSelectArea("TRBNLVRO")
		TRBNLVRO->(dbGoTop())      
		If TRBNLVRO->(!Eof())     
			Do While  TRBNLVRO->(!Eof())     	
				aAdd(aNrLvro,{TRBNLVRO->TES,  TRBNLVRO->NLIVRO})
				TRBNLVRO->(DbSkip())	     
			End
		Endif


		cQryLvro:=" SELECT DISTINCT F3_FILIAL,F3_TIPOMOV, F3_NFISCAL DOC, F3_SERIE SERIE, F3_CLIEFOR FORNECE,F3_LOJA LOJA, F3_ESPECIE ESPECIE, F3_EMISSAO EMISSAO,"
		If cTipo=="COM"
			cQryLvro+=" A2_CGC RUC, A2_NREDUZ NOME, A2_COD COD, A2_LOJA LOJA, A2_EST EST "
		Else
			cQryLvro+=" A1_CGC RUC, A1_NREDUZ NOME, A1_COD COD, A1_LOJA LOJA, A1_EST EST"
		Endif
		cQryLvro+=" FROM "+RetsqlName("SF3")+" SF3 "
		If cTipo=="COM"
			cQryLvro+=" INNER JOIN "+RetsqlName("SA2")+" SA2 ON "
			cQryLvro+=" F3_CLIEFOR=A2_COD "
			cQryLvro+=" AND F3_LOJA=A2_LOJA "
			cQryLvro+=" AND SA2.D_E_L_E_T_='' "
			cQryLvro+=" LEFT JOIN "+RetsqlName("SF1")+" SF1 ON F1_DOC= F3_NFISCAL AND F1_SERIE=  F3_SERIE  AND F1_FORNECE = F3_CLIEFOR "
		Else
			cQryLvro+=" INNER JOIN "+RetsqlName("SA1")+" SA1 ON "
			cQryLvro+=" F3_CLIEFOR=A1_COD "
			cQryLvro+=" AND F3_LOJA=A1_LOJA "
			cQryLvro+=" AND SA1.D_E_L_E_T_='' "
			cQryLvro+=" LEFT JOIN "+RetsqlName("SF2")+" SF2 ON F2_DOC= F3_NFISCAL AND F2_SERIE=  F3_SERIE  AND F2_CLIENTE = F3_CLIEFOR "

		Endif	
		cQryLvro+=" WHERE F3_ESPECIE  IN ('NF','NDP','NCP','NDC','NCC','NDE','NCE','NDI','NCI') "
		If cTipo=="COM"  
			cQryLvro+= " AND F3_TIPOMOV= 'C' AND F1_TIPNOTA !='14' "
		Else
			cQryLvro+= " AND F3_TIPOMOV= 'V' AND F2_TIPNOTA !='14' "	
		EndIf	


		cQryLvro+=" AND F3_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "	

		If !Empty(cDtIni) .And. !Empty(cDtFim)
			cQryLvro+=" AND F3_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "	
		ElseIf !Empty(cDtIni) .And. Empty(cDtFim)
			cQryLvro+=" AND F3_EMISSAO >= '"+cDtIni+"' "	
		ElseIf Empty(cDtIni) .And. Empty(cDtFim)
			cQryLvro+=" AND F3_EMISSAO <= '"+cDtFim+"' "	
		Endif
		cQryLvro+=" AND SF3.D_E_L_E_T_='' "        
		cQryLvro+=" ORDER BY F3_EMISSAO,F3_NFISCAL , F3_SERIE , F3_CLIEFOR ,F3_LOJA , F3_ESPECIE "

		If Select("TRBLVRO")>0
			DbSelectArea("TRBLVRO")	
			TRBLVRO->(DbCloseArea())
		Endif

		cTRBLvro := ChangeQuery(cQryLvro)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLvro ) ,"TRBLvro", .T., .F.)

		DbSelectArea("TRBLvro")
		TRBLvro->(dbGoTop())      
		If TRBLvro->(!Eof())      
			Do While TRBLvro->(!Eof()) 
				DbSelectArea("SF3")
				SF3->(DbSetOrder(5))//F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
				SF3->(DbGoTop())
				If MsSeek(TRBLvro->F3_FILIAL+TRBLvro->SERIE+TRBLvro->DOC+TRBLvro->FORNECE+TRBLvro->LOJA,.T.)
					nQtdReg++
					nVlrExe:=0   
					nVlrIng:=0    
					nBasI05:=0
					nVlrI05:=0
					nBasI10:=0			
					nVlrI10:=0
					Do While SF3->(!EOF()) .And.  SF3->(F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA)==TRBLvro->F3_FILIAL+TRBLvro->SERIE+ TRBLvro->DOC+TRBLvro->FORNECE + TRBLvro->LOJA
						nPos:=Ascan(aNrLvro,{|x|Alltrim(x[1])==Alltrim(SF3->F3_TES)})					
						nVlrExe+=SF3->F3_EXENTAS
						nVlrIng+=SF3->F3_VALCONT		
						If nPos>0   
							cLivr:=aNrLvro[nPos][2]//Numero Livro
							If &("F3_ALQIMP"+cLivr)==10
								nBasI10+=&("F3_BASIMP"+cLivr)
								nVlrI10+=&("F3_VALIMP"+cLivr)
							ElseIf &("F3_ALQIMP"+cLivr)==5
								nBasI05+=&("F3_BASIMP"+cLivr)				
								nVlrI05+=&("F3_VALIMP"+cLivr)
							Endif                            
						Else
							Exit
						Endif
						SF3->(DbSkip())      
					End
					If cTipo=="VEN" .And. TRBLvro->F3_TIPOMOV=="V"
						//Tipo NF(1-Nota Fatura|2-Nota de Debito|3-Nota de Credito|0-imposto consolidados)
						If "NF" $ Alltrim(TRBLvro->ESPECIE)
							cTpNf:="1"
						ElseIf Alltrim(TRBLvro->ESPECIE) $ ("NDC|NCE") //DEBITO
							cTpNf:="2"				
						ElseIf Alltrim(TRBLvro->ESPECIE) $ ("NCC|NDE")   // CREDITO
							cTpNf:="3"
						Else	      
							cTpNf:="0"
						Endif
						DbSelectArea("VEN")   
						VEN->(dbSetOrder(1))//VEN_NUMDOC+VEN_TIPDOC+VEN_EMISSA
						VEN->(dbGoTop())
						RecLock("VEN",.T.)   
						VEN->VEN_TIPREG := "2"
						VEN->VEN_RUC    := Transform(TRBLvro->RUC,"@R XXXXXXXXXXXXXXX")
						VEN->VEN_DV     := Iif(TRBLvro->COD+TRBLvro->LOJA=="99999901","0",Substr(Alltrim(TRBLvro->RUC),Len(Alltrim(TRBLvro->RUC)),1))
						VEN->VEN_NOMCLI := TRBLvro->NOME
						VEN->VEN_TIPDOC := cTpNf
						VEN->VEN_NUMDOC := Transform(TRBLvro->DOC,PesqPict("SF3","F3_NFISCAL"))
						VEN->VEN_EMISSA := Substr(TRBLvro->EMISSAO,7,2)+"/"+Substr(TRBLvro->EMISSAO,5,2)+"/"+Substr(TRBLvro->EMISSAO,1,4)//Formato Valido DD/MM/AAAA ou DD-MM-AAAA
						VEN->VEN_BAS010 := Transform(Round(nBasI10,0),"@E 9999999999999999")
						VEN->VEN_VLR010 := Transform(Round(nVlrI10,0),"@E 9999999999999999")
						VEN->VEN_BAS005 := Transform(Round(nBasI05,0),"@E 9999999999999999")
						VEN->VEN_VLR005 := Transform(Round(nVlrI05,0),"@E 9999999999999999")
						VEN->VEN_VLREXE := Transform(Round(nVlrExe,0),"@E 9999999999999999")
						VEN->VEN_VLRING := Transform(Round(nVlrIng,0),"@E 9999999999999999")				

						nSinal:=1
						If cTpNf=="3"
							nSinal := -1
						EndIf
						nBase10:= nBase10 + (nBasI10 * nSinal)
						nBase05:= nBase05 + (nBasI05 * nSinal)
						nVl10:= nVl10+ (nVlrI10 * nSinal)
						nVl05:= nVl05+ (nVlrI05 * nSinal)
						nExenta:= nExenta + (nVlrExe * nSinal)
						nTVlrIng:= nTVlrIng + (nVlrIng * nSinal)

						Aadd(aLogRel,PADR(VEN->VEN_RUC,20)+PADR(VEN->VEN_DV,5)+PADR(VEN->VEN_NOMCLI,30)+PADR(TRBLvro->ESPECIE,5)+PADR(VEN->VEN_TIPDOC,5)+PADR(VEN->VEN_NUMDOC,22)+PADR(VEN->VEN_EMISSA,10)+;
						PADR(Transform(Round(nBasI10 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrI10 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nBasI05 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrI05 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrExe * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(VEN->VEN_VLRING,20)) 					
						VEN->(MsUnlock())


					ElseIf cTipo=="COM"  .And. TRBLvro->F3_TIPOMOV=="C"
						//Tipo NF(1-Nota Fatura|2-Nota de Debito|3-Nota de Credito|4-Despacho|5-AutoFatura)
						If "NF" $ Alltrim(TRBLvro->ESPECIE)
							cTpNf:="1"                                          
						ElseIf Alltrim(TRBLvro->ESPECIE) $ "NDP|NCI"  //DEBITO
							cTpNf:="2"				
						ElseIf Alltrim(TRBLvro->ESPECIE) $ "NCP|NDI"  // CREDITO
							cTpNf:="3"
						ElseIf Alltrim(TRBLvro->COD+TRBLvro->LOJA)=="99999901" .Or. TRBLvro->EST=="EX"
							cTpNf:="4"
						ElseIf Alltrim(TRBLvro->COD+TRBLvro->LOJA)=="99999901"
							cTpNf:="5"				
						Endif
						DbSelectArea("COM")   
						COM->(dbSetOrder(1))//COM_NUMDOC+COM_TIPDOC+COM_EMISSA
						COM->(dbGoTop())
						RecLock("COM",.T.)   
						COM->COM_TIPREG := "2"
						COM->COM_RUC    := Transform(TRBLvro->RUC,"@R XXXXXXXXXXXXXXX")
						COM->COM_DV     := Iif(cTpNf=="4","0",Substr(Alltrim(TRBLvro->RUC),Len(Alltrim(TRBLvro->RUC)),1))
						COM->COM_NOMFOR := TRBLvro->NOME
						COM->COM_NUMTIM := Replicate("0",20)								
						COM->COM_TIPDOC := cTpNf				
						COM->COM_NUMDOC := TRBLvro->DOC
						COM->COM_EMISSA := Substr(TRBLvro->EMISSAO,7,2)+"/"+Substr(TRBLvro->EMISSAO,5,2)+"/"+Substr(TRBLvro->EMISSAO,1,4)//Formato Valido DD/MM/AAAA ou DD-MM-AAAA
						COM->COM_BAS010 := Transform(Round(nBasI10,0),"@E 9999999999999999")
						COM->COM_VLR010 := Transform(Round(nVlrI10,0),"@E 9999999999999999")
						COM->COM_BAS005 := Transform(Round(nBasI05,0),"@E 9999999999999999")
						COM->COM_VLR005 := Transform(Round(nVlrI05,0),"@E 9999999999999999")
						COM->COM_VLREXE := Transform(Round(nVlrExe,0),"@E 9999999999999999")

						nSinal:=1
						If cTpNf=="3"
							nSinal := -1
						EndIf

						Aadd(aLogRel,PADR(COM->COM_RUC,20)+PADR(COM->COM_DV,5)+PADR(COM->COM_NOMFOR,30)+PADR(TRBLvro->ESPECIE,5);
						+PADR(COM->COM_TIPDOC,5)+PADR(COM->COM_NUMDOC,22)+PADR(COM->COM_EMISSA,10);
						+PADR(Transform(Round(nBasI10 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrI10 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nBasI05 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrI05 * nSinal,0),"@E 9999999999999999"),20); 
						+PADR(Transform(Round(nVlrExe * nSinal,0),"@E 9999999999999999"),20)) 

						COM->(MsUnlock())  

						nBase10:= nBase10 + (nBasI10 * nSinal)
						nBase05:= nBase05 + (nBasI05 * nSinal)
						nVl10:= nVl10+ (nVlrI10 * nSinal)
						nVl05:= nVl05+ (nVlrI05 * nSinal)
						nExenta:= nExenta + (nVlrExe * nSinal)
						nTVlrExe:= nTVlrExe + (nVlrExe  * nSinal)
					Endif  
				Endif                                                                                                                                   
				TRBLvro->(DbSkip())      
			End                                                               
			Aadd(aLogRel,PADR(" ",20))
			Aadd(aLogRel,PADR("Totales",20))
			Aadd(aLogRel, STR0011 +"....:" + Transform(Round(nBase10,0),"@E 9999999999999999")  )
			Aadd(aLogRel, STR0012 +"...:"  + Transform(Round(nVl10,0),"@E 9999999999999999")    )
			Aadd(aLogRel, STR0013 +".....:"+ Transform(Round(nBase05,0),"@E 9999999999999999")  )
			Aadd(aLogRel, STR0014 +"....:" + Transform(Round(nVl05,0),"@E 9999999999999999")    )
			Aadd(aLogRel, STR0015 +"....:" + Transform(Round(nTVlrExe,0),"@E 9999999999999999"))
		Else
			Aadd(aLogreg,STR0023)	//"Nao ha registros a serem gerados"
		Endif	
		Aadd(aLogreg,Replicate("-",80))	
		Aadd(aLogreg,STR0024+SPACE(1)+Alltrim(Str(nQtdReg)))	//"Quantidade de Registros gerado: "
		Aadd(aLogreg,Replicate("-",80))

		RecLock("CAB",.T.)                      
		CAB->CAB_TIPO	 :="1"	
		CAB->CAB_TIPREP  :=Substr(aParam[1][1],1,1)
		CAB->CAB_TIPINF  :=Iif(cTipo=="VEN","921","911")	
		CAB->CAB_CDFORM  :=Iif(cTipo=="VEN","221","211")	
		CAB->CAB_RUCAGI  :=aParam[1][2]
		CAB->CAB_DVAGIN  :=aParam[1][3]
		CAB->CAB_NOMAGI  :=aParam[1][4]	
		CAB->CAB_RUCREP  :=aParam[2][1]
		CAB->CAB_DVREPL  :=aParam[2][2]
		CAB->CAB_NOMREP  :=aParam[2][3]
		CAB->CAB_NUMREG  := Transform(nQtdReg,"@E 99999")
		CAB->CAB_VLRTOT  := Transform(Round(IIF(cTipo=="VEN",nTVlrIng,nTVlrExe),0),"@E 9999999999999999999")
		CAB->(MsUnlock())			                               
	Else            
		Aadd(aLogRel,STR0032)//"Nao existem registros a serem processados"
		Aadd(aLogreg,Replicate("-",80))	
		Aadd(aLogreg,STR0025)//"Periodo informado na data inicial e data final deve ser do mesmo mes e ano. "
		Aadd(aLogreg,Replicate("-",80))
	Endif
	
	IMPLOCPAR(aLogRel)
	
	//leem
	If oTmpTable1 <> Nil   
		oTmpTable1:Delete()
		oTmpTable1 := Nil
	EndIf

Return(aLogReg)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao ณLocTrb        บAutor  ณ Marcos Kato       บ Data ณ  30/03/04   บฑฑ
ฑฑฬอออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.  ณMontagem dos arquivos de trabalho.                             บฑฑ
ฑฑฬอออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetornoณExpA -> aTrbs - Array contendo alias abertos pela funcao       บฑฑ
ฑฑฬอออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso    ณ                                                               บฑฑ
ฑฑศอออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LocTrbs(cTipo)
	Local cArqVen		:= "", cArqVenB		:= ""
	Local cArqCom		:= "", cArqComB		:= ""
	Local cArqCab		:= ""
	Local aStruVen		:= {}
	Local aStruCom		:= {}         
	Local aStruCab		:= {}         
	Local aOrdem := {}         
	If cTipo=="VEN"
		AADD(aStruVen,{"VEN_TIPREG"	,"C",001,0})//Tipo de Registro
		AADD(aStruVen,{"VEN_RUC"	,"C",015,0})//RUC
		AADD(aStruVen,{"VEN_DV"	    ,"C",001,0})//DV
		AADD(aStruVen,{"VEN_NOMCLI"	,"C",080,0})//Nome do Cliente
		AADD(aStruVen,{"VEN_TIPDOC"	,"C",002,0})//Tipo documento              
		AADD(aStruVen,{"VEN_NUMDOC"	,"C",020,0})//Numero Documento
		AADD(aStruVen,{"VEN_EMISSA"	,"C",010,0})//emissao
		AADD(aStruVen,{"VEN_BAS010"	,"C",020,0})//Base imposto 10%
		AADD(aStruVen,{"VEN_VLR010"	,"C",020,0})//Valor imposto 10%
		AADD(aStruVen,{"VEN_BAS005"	,"C",020,0})//Base imposto 5%
		AADD(aStruVen,{"VEN_VLR005"	,"C",020,0})//Valor imposto 5%
		AADD(aStruVen,{"VEN_VLREXE"	,"C",020,0})//Valor da compra/venda insenta
		AADD(aStruVen,{"VEN_VLRING"	,"C",020,0})//Valor da compra/venda insenta

		//Creacion de Objeto VEN
		oTmpTable1 := FWTemporaryTable():New("VEN") //leem
		oTmpTable1:SetFields( aStruVen ) //leem

		aOrdem	:=	{"VEN_NUMDOC","VEN_TIPDOC","VEN_EMISSA"} //leem

		oTmpTable1:AddIndex("IN1", aOrdem) //leem

		oTmpTable1:Create() //leem


	Else
		AADD(aStruCom,{"COM_TIPREG"	,"C",001,0})//Tipo de Registro
		AADD(aStruCom,{"COM_RUC"	,"C",015,0})//RUC
		AADD(aStruCom,{"COM_DV"	    ,"C",001,0})//DV
		AADD(aStruCom,{"COM_NOMFOR"	,"C",080,0})//Nome do fornecedor
		AADD(aStruCom,{"COM_NUMTIM"	,"C",020,0})//Numero Timbrado
		AADD(aStruCom,{"COM_TIPDOC"	,"C",002,0})//Tipo documento              
		AADD(aStruCom,{"COM_NUMDOC"	,"C",020,0})//Numero Documento
		AADD(aStruCom,{"COM_EMISSA"	,"C",010,0})//emissao
		AADD(aStruCom,{"COM_BAS010"	,"C",020,0})//Base imposto 10%
		AADD(aStruCom,{"COM_VLR010"	,"C",020,0})//Valor imposto 10%
		AADD(aStruCom,{"COM_BAS005"	,"C",020,0})//Base imposto 5%
		AADD(aStruCom,{"COM_VLR005"	,"C",020,0})//Valor imposto 5%
		AADD(aStruCom,{"COM_VLREXE"	,"C",020,0})//Valor da compra/venda insenta

		//Creacion de Objeto COM
		oTmpTable1 := FWTemporaryTable():New("COM") //leem
		oTmpTable1:SetFields( aStruCom ) //leem

		aOrdem	:=	{"COM_NUMDOC","COM_TIPDOC","COM_EMISSA"} //leem

		oTmpTable1:AddIndex("IN1", aOrdem) //leem

		oTmpTable1:Create() //leem


	Endif
	AADD(aStruCab,{"CAB_TIPO"   ,"C",001,0})
	AADD(aStruCab,{"CAB_TIPREP" ,"C",001,0})
	AADD(aStruCab,{"CAB_TIPINF" ,"C",003,0})
	AADD(aStruCab,{"CAB_CDFORM" ,"C",003,0})
	AADD(aStruCab,{"CAB_RUCAGI" ,"C",015,0})
	AADD(aStruCab,{"CAB_DVAGIN" ,"C",001,0})
	AADD(aStruCab,{"CAB_NOMAGI" ,"C",080,0})
	AADD(aStruCab,{"CAB_RUCREP" ,"C",015,0})
	AADD(aStruCab,{"CAB_DVREPL" ,"C",001,0})
	AADD(aStruCab,{"CAB_NOMREP" ,"C",080,0})
	AADD(aStruCab,{"CAB_NUMREG"	,"C",005,0})
	AADD(aStruCab,{"CAB_VLRTOT"	,"C",020,0})


	//cArqCab	:=	CriaTrab(aStruCab)	
	//dbUseArea(.T.,__LocalDriver,cArqCab,"CAB")

	//Creacion de Objeto COM
	oTmpTable2 := FWTemporaryTable():New("CAB") //leem
	oTmpTable2:SetFields( aStruCab ) //leem

	oTmpTable2:Create() //leem	
Return   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IMPLOCPARบ Autor ณ Marcos Kato		 บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Arquivo magnetico		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Intermedic                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function IMPLOCPAR(aLogArq)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cPerg			:= ""	
	Local cDesc1        := STR0026//"Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := STR0027//"das inconsistencias da geracao do arquivo magnetivo "
	Local cDesc3        := STR0028//""
	Local cPict         := ""
	Local titulo       	:= aLogArq[1]
	Local Cabec1       	:= aLogArq[4]
	Local Cabec2       	:= aLogArq[2]
	Local Imprime      	:= .T.
	Private _nLin      	:= 80
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 80
	Private tamanho     := aLogArq[3]
	Private nomeprog    := "LOCPAR" // Coloque aqui o nome do programa para impressao no cabecalho
	Private aReturn     := {STR0029, 1,STR0030 , 2, 2, 1, "", 1}/// "Zebrado"#"Administracao"
	Private nLastKey    := 0
	Private m_pag       := 01 
	Private wnrel       := "LOCPAR" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString 	:= "SF3"
	Default aLogArq		:= {}

	IF lAutomato
		return nil
	ENDIF
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a interface padrao com o usuario...                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,"",.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| LocParImp(Cabec1,Cabec2,Titulo,_nLin,aLogArq) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณLocParImpบ Autor ณ Marcos Kato        บ Data ณ  16/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Montagem do relatorio									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function LocParImp(Cabec1,Cabec2,Titulo,_nLin,aLogArq)
	Local nCont:=0
	_nLin:= Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
	For nCont:=5 To Len(aLogArq)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAbortPrint
			@_nLin,00 PSAY STR0031//"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		@_nLin++
		@_nLin,000 psay aLogArq[nCont]

		If nCont>=50
			_nLin:= Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)	
		Endif   	
	Next	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SET DEVICE TO SCREEN
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aReturn[5]==1
		dbCommitAll()
		Set Printer To
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
Return
