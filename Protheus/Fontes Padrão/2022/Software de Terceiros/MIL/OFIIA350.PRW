#include "tbiconn.ch"
#INCLUDE "OFIIA350.ch"                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIIA350  ºAutor  ³Fabio               º Data ³  09/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Levanta a Informacoes diarias de Pecas                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA350(cCodMar,cEmpr,cFil)

Private lAuto := .f.
     
If cCodMar # NIL    
	
	lAuto := .t.
	If ValType(cCodMar) == "A"  && No processo WorkFlow o parameto e passado como vetor

		cEmpr   := cCodMar[2]
		cFil    := cCodMar[3]
		cCodMar := cCodMar[1]
	
		nModulo := 11
		cModulo := "OFI"
		__cInternet := 'AUTOMATICO'
	
		If Type("cArqTab")=="U"
			cArqTab:=""
		EndIf	
	
		cFOPENed := ""
	
		dDataBase:= Date()

		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Tables 'SD2' Modulo "OFI"
	
	EndIf
	
EndIf

If GETNEWPAR("MV_AUTGIRO","N") # "S"
	MsgStop(STR0002,STR0001)  //  Esta opcao somente podera ser utilizada para autogiro! # Atencao       
	Return                                
EndIf

If File("EDI\EXPORTA\DE"+STRZERO(DAY(DDATABASE),2)+STRZERO(MONTH(DDATABASE),2)+RIGHT(STRZERO(YEAR(DDATABASE),4),2)+".TXT")
	If !MsgYesNo(STR0003+STRZERO(DAY(DDATABASE),2)+STRZERO(MONTH(DDATABASE),2)+RIGHT(STRZERO(YEAR(DDATABASE),4),2)+STR0004,STR0001) // O arquivo DE  #  ".TXT ja foi processado! Deseja processar novamente? #  Atencao
		Return
	EndIf
EndIf

If lAuto

	Pergunte("OFIA70", .F. )
	MV_PAR01 := cCodMar

Else

	//If !Pergunte("OIA350",.t.) 
	If !Pergunte("OFIA70",.t.) 
	   Return
	EndIf

EndIf
      
If lAuto
	FS_IA350()
Else
	Processa( {|| FS_IA350() })
EndIf   

Return             

Function FS_IA350()

Local cAliasSC7 := "QTDPED"
Local cAliasSD2 := "QTDVEN"
Local cAliasVE6 := "QTDPER"
Local cAliasSB1 := "QTDPRO"
Local cQuery    := ""
Local dDataIni  := Ctod("  /  /  ")
Local dDataFin  := Ctod("  /  /  ")
Local dDataMIni := Ctod("  /  /  ")

Private cRecInt := ""
             
/*DbSelectArea("VIW")
DbSetOrder(1)
If DbSeek( xFilial("VIW") + Dtos(dDataBase) )

	If !lAuto
		MsgStop("Data " + Transform(dDataBase,"@D") + " ja processada! Nao e possivel processar novamente." ,"Atencao")
	EndIf		
	Return(.f.)
   
EndIf
*/

DbSelectArea("VE4")
DbSetOrder(1)
DbSeek( xFilial("VE4") + MV_PAR01 )
                 
DbSelectArea("SB1")
DbSetOrder(7)
DbSeek( xFilial("SB1") + VE4->VE4_GRUITE )
                        
If !lAuto
	ProcRegua(SB1->(RecCount()))
EndIf
                      
Begin Transaction

	dDataFin  := dDataBase
	dDataIni  := ( dDataFin-365 )

	dDataMIni := Ctod( "01/"+StrZero(Month(dDataBase),2)+"/"+Substr(StrZero(Year(dDataBase),4),3,2) )

	&& Levanta registro enviados pelo sistema antigo durante o 1o ano de uso
	If SB1->(FieldPos("B1_DULTVEN")) # 0

		cQuery    += "SELECT B1_COD "
		cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
		cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery    += "SB1.B1_DULTVEN BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
		cQuery    += "SB1.B1_AUTGIRO='1' AND "
		cQuery    += "SB1.B1_ATIVO <> 'N' AND "
		cQuery    += "SB1.D_E_L_E_T_=' ' AND "
	
		cQuery    += "SB1.B1_GRUPO IN "
		cQuery    += "( SELECT BM_GRUPO "
		cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
		cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
		cQuery    += "SBM.BM_PROORI='1' AND "
		cQuery    += "SBM.D_E_L_E_T_=' ' ) AND "
	
		cQuery    += "SB1.B1_COD IN "					
		cQuery    += "( SELECT B5_COD "
		cQuery    += "FROM "+RetSqlName("SB5")+" SB5 "
		cQuery    += "WHERE SB5.B5_FILIAL='"+xFilial("SB5")+"' AND "
		cQuery    += "SB5.D_E_L_E_T_=' ' AND "
		cQuery    += "( ( SB5.B5_STATUS <> 'O' AND SB1.B1_ATIVO <> 'N' ) OR ( SB5.B5_STATUS <> 'O' OR SB1.B1_ATIVO <> 'N' ) ) ) "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSB1, .F., .T. ) 

		Do While !( cAliasSB1 )->( Eof() ) 
	
			If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim(( cAliasSB1 )->B1_CODITE)) == 8 )
	
				&& Levanta quantidade atual
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek( xFilial("SB2") + ( cAliasSB1 )->B1_COD + ( cAliasSB1 )->B1_LOCPAD )

				FS_GRVVIW(( cAliasSB1 )->B1_GRUPO,;
							 ( cAliasSB1 )->B1_CODITE,;
							 SB2->B2_QATU,;
							 0,;
							 0, 0 )
				         
			EndIf
	
		   ( cAliasSB1 )->( DbSkip() ) 					     
	
		EndDo
	
		( cAliasSB1 )->( dbCloseArea() ) 

	EndIf
	

	&& Levanta quantidade vendida no mes 01 ao dia da geracao
	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
//	cQuery    += "SD2.D2_COD='"+SB1->B1_COD+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) AND "

	cQuery    += "SD2.D2_COD IN "					
	cQuery    += "( SELECT B1_COD "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
//	cQuery    += "SB1.B1_AUTGIRO='1' AND "
//	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_GRUPO IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' ) ) "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSD2, .F., .T. ) 
                                           
	Do While !( cAliasSD2 )->( Eof() ) 

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + ( cAliasSD2 )->( D2_COD ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim(SB1->B1_CODITE)) == 8 )

			&& Levanta quantidade atual
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
		
			FS_GRVVIW(SB1->B1_GRUPO,;
						 SB1->B1_CODITE,;
						 SB2->B2_QATU,;
						 0,;
						 If( SB1->B1_AUTGIRO # "0" , ( cAliasSD2 )->( D2_QUANT ), 0) , 0 )
			         
//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
			
		EndIf

	   ( cAliasSD2 )->( DbSkip() ) 					     

	EndDo

	( cAliasSD2 )->( dbCloseArea() ) 

	&& Levanta quantidade vendida no ano, se teve venda no ano cria registro com quantidade 0
	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
//	cQuery    += "SD2.D2_COD='"+SB1->B1_COD+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataIni) +"' AND '"+DTOS(dDataFin)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) AND "

	cQuery    += "SD2.D2_COD IN "					
	cQuery    += "( SELECT B1_COD "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
//	cQuery    += "SB1.B1_AUTGIRO='1' AND "
//	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_GRUPO IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' ) AND "

	cQuery    += "SB1.B1_COD IN "					
	cQuery    += "( SELECT B5_COD "
	cQuery    += "FROM "+RetSqlName("SB5")+" SB5 "
	cQuery    += "WHERE SB5.B5_FILIAL='"+xFilial("SB5")+"' AND "
	cQuery    += "SB5.D_E_L_E_T_=' ' AND "
	cQuery    += "( ( SB5.B5_STATUS <> 'O' AND SB1.B1_ATIVO <> 'N' ) OR ( ( SB5.B5_STATUS <> 'O' OR SB1.B1_ATIVO <> 'N' ) AND "

	cQuery    += "( SB5.B5_COD IN "
	cQuery    += "( SELECT B2_COD "
	cQuery    += "FROM "+RetSqlName("SB2")+" SB2 "
	cQuery    += "WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND "
	cQuery    += "SB2.B2_LOCAL='01' AND "
	cQuery    += "SB2.D_E_L_E_T_=' ' AND "
	cQuery    += "( SB2.B2_QATU>0 OR "

	cQuery    += "SB2.B2_COD IN "
	cQuery    += "( SELECT D2_COD "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) ) ) ) ) ) ) ) "

             
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSD2, .F., .T. ) 

/*
	&& Levanta quantidade vendida no ano, se teve venda no ano cria registro com quantidade 0
	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
//	cQuery    += "SD2.D2_COD='"+SB1->B1_COD+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataIni) +"' AND '"+DTOS(dDataFin)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) AND "

	cQuery    += "SD2.D2_COD IN "					
	cQuery    += "( SELECT B1_COD "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
//	cQuery    += "SB1.B1_AUTGIRO='1' AND "
	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_GRUPO IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' ) ) AND "

	cQuery    += "SD2.D2_COD IN "					
	cQuery    += "( SELECT B5_COD "
	cQuery    += "FROM "+RetSqlName("SB5")+" SB5 "
	cQuery    += "WHERE SB5.B5_FILIAL='"+xFilial("SB5")+"' AND "
	cQuery    += "SB5.D_E_L_E_T_=' ' AND "
	cQuery    += "( SB5.B5_STATUS <> 'O' OR (  SB5.B5_STATUS='O' AND "

	cQuery    += "SB5.B5_COD IN "
	cQuery    += "( SELECT B2_COD "
	cQuery    += "FROM "+RetSqlName("SB2")+" SB2 "
	cQuery    += "WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND "
	cQuery    += "SB2.B2_LOCAL='01' AND "
	cQuery    += "SB2.D_E_L_E_T_=' ' AND "
	cQuery    += "( SB2.B2_QATU>0 OR "

	cQuery    += "SB2.B2_COD IN "
	cQuery    += "( SELECT D2_COD "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) ) ) ) ) ) "
*/
                                           
	Do While !( cAliasSD2 )->( Eof() ) 

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + ( cAliasSD2 )->( D2_COD ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim(SB1->B1_CODITE)) == 8 )

			&& Levanta quantidade atual
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )

			FS_GRVVIW(SB1->B1_GRUPO,;
						 SB1->B1_CODITE,;
						 SB2->B2_QATU,;
						 0,;
						 0, 0 )
			         
//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
			
		EndIf

	   ( cAliasSD2 )->( DbSkip() ) 					     

	EndDo

	( cAliasSD2 )->( dbCloseArea() ) 


	&& Levanta venda perdida no mes 01 ao dia do levantamento
	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("VE6")+" VE6 "
	cQuery    += "WHERE VE6.VE6_FILIAL='"+xFilial("VE6")+"' AND "
//	cQuery    += "VE6.VE6_GRUITE='"+SB1->B1_GRUPO+"' AND "
//	cQuery    += "VE6.VE6_CODITE='"+SB1->B1_CODITE+"' AND "
	cQuery    += "VE6.VE6_DATREG BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "VE6.VE6_INDREG='1' AND "
	cQuery    += "VE6.VE6_CODMOT='002' AND "
	cQuery    += "VE6.D_E_L_E_T_=' ' AND "

	cQuery    += "VE6.VE6_CODITE IN "					
	cQuery    += "( SELECT B1_CODITE "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
//	cQuery    += "SB1.B1_AUTGIRO='1' AND "
	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_COD IN "
	cQuery    += "( SELECT D2_COD "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
//	cQuery    += "SD2.D2_COD='"+SB1->B1_COD+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) ) AND "

	cQuery    += "VE6.VE6_GRUITE IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' )"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVE6, .F., .T. ) 

	Do While !( cAliasVE6 )->( Eof() ) 

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + ( cAliasVE6 )->( VE6_GRUITE ) + ( cAliasVE6 )->( VE6_CODITE ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim( ( cAliasVE6 )->( VE6_CODITE ) )) == 8 )

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
		                         
			FS_GRVVIW(( cAliasVE6 )->( VE6_GRUITE ),;
						 ( cAliasVE6 )->( VE6_CODITE ),;
						 SB2->B2_QATU,;
						 0,;
						 0, If( SB1->B1_AUTGIRO # "0" , ( cAliasVE6 )->( VE6_QTDITE ) , 0 ) )
			         
//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
			
			
		EndIf
	
	   ( cAliasVE6 )->( DbSkip() ) 					     
		   
	EndDo
                  
	( cAliasVE6 )->( dbCloseArea() ) 

	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("VE6")+" VE6 "
	cQuery    += "WHERE VE6.VE6_FILIAL='"+xFilial("VE6")+"' AND "
//	cQuery    += "VE6.VE6_GRUITE='"+SB1->B1_GRUPO+"' AND "
//	cQuery    += "VE6.VE6_CODITE='"+SB1->B1_CODITE+"' AND "
	cQuery    += "VE6.VE6_DATREG BETWEEN '"+ Dtos(dDataIni) +"' AND '"+DTOS(dDataFin)+"' AND "
	cQuery    += "VE6.VE6_INDREG='1' AND "
	cQuery    += "VE6.VE6_CODMOT='002' AND "
	cQuery    += "VE6.D_E_L_E_T_=' ' AND "


	cQuery    += "VE6.VE6_CODITE IN "					
	cQuery    += "( SELECT B1_CODITE "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
	cQuery    += "SB1.B1_AUTGIRO='1' AND "
	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_COD IN "
	cQuery    += "( SELECT D2_COD "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
//	cQuery    += "SD2.D2_COD='"+SB1->B1_COD+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) ) AND "

	cQuery    += "VE6.VE6_GRUITE IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' )"


	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVE6, .F., .T. ) 

	Do While !( cAliasVE6 )->( Eof() ) 

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + ( cAliasVE6 )->( VE6_GRUITE ) + ( cAliasVE6 )->( VE6_CODITE ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim( ( cAliasVE6 )->( VE6_CODITE ) )) == 8 )

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
		                         
			FS_GRVVIW(( cAliasVE6 )->( VE6_GRUITE ),;
						 ( cAliasVE6 )->( VE6_CODITE ),;
						 SB2->B2_QATU,;
						 0,;
						 0, 0 )
			         
//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
			
			
		EndIf
	
	   ( cAliasVE6 )->( DbSkip() ) 					     
		   
	EndDo
                  
	( cAliasVE6 )->( dbCloseArea() ) 


	&& Levanta quantidade pedida no mes 01 ao dia da geracao
	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("SC7")+" SC7 "
	cQuery    += "WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
//	cQuery    += "SC7.C7_PRODUTO='"+SB1->B1_COD+"' AND "
//	cQuery    += "SC7.C7_EMISSAO BETWEEN '"+ Dtos(dDataMIni) +"' AND '"+DTOS(dDataBase)+"' AND "
	cQuery    += "SC7.C7_QUANT > SC7.C7_QUJE AND "
	cQuery    += "SC7.C7_FORNECE='"+VE4->VE4_CODFOR+"' AND "
	cQuery    += "SC7.C7_LOJA='"+VE4->VE4_LOJFOR+"' AND "
	cQuery    += "SC7.D_E_L_E_T_=' ' AND "


	cQuery    += "SC7.C7_PRODUTO IN "					
	cQuery    += "( SELECT B1_COD "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
//	cQuery    += "SB1.B1_AUTGIRO='1' AND "
//	cQuery    += "SB1.B1_ATIVO <> 'N' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

//	cQuery    += "( SB1.B1_AUTGIRO='1' OR ( SB1.B1_AUTGIRO='0' AND "

	cQuery    += "SB1.B1_COD IN "
	cQuery    += "( SELECT D2_COD "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery    += "SD2.D2_EMISSAO BETWEEN '"+ Dtos(dDataIni) +"' AND '"+DTOS(dDataFin)+"' AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "

	cQuery    += "SD2.D2_TES IN "					
	cQuery    += "( SELECT F4_CODIGO "
	cQuery    += "FROM "+RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_OPEMOV='05' AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) AND "
//	cQuery    += "SF4.D_E_L_E_T_=' ' ) ) ) ) AND "


	cQuery    += "SB1.B1_GRUPO IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' ) ) AND "

	cQuery    += "SC7.C7_NUM IN "
	cQuery    += "( SELECT VEI_NUM "
	cQuery    += "FROM "+RetSqlName("VEI")+" VEI "
	cQuery    += "WHERE VEI.VEI_FILIAL='"+xFilial("VEI")+"' AND "
	cQuery    += "( VEI.VEI_TIPPED='1 ' OR VEI.VEI_TIPPED='3 ' OR VEI.VEI_TIPPED='01' OR VEI.VEI_TIPPED='03' ) AND "
	cQuery    += "VEI.D_E_L_E_T_=' ' ) "


	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSC7, .F., .T. ) 

	Do While !( cAliasSC7 )->( Eof() ) 

		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + ( cAliasSC7 )->( C7_PRODUTO ) )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + ( cAliasSC7 )->( C7_PRODUTO ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim( SB1->B1_CODITE )) == 8 )
	
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
				
			If ( (SB1->B1_ATIVO # "N" .And. SB5->B5_STATUS # "O") .Or. ( (SB1->B1_ATIVO == "N" .Or. SB5->B5_STATUS == "O") .And. SB2->B2_QATU > 0 ) )

				FS_GRVVIW(SB1->B1_GRUPO,;
							 SB1->B1_CODITE,;
							 SB2->B2_QATU,;
							 ( ( cAliasSC7 )->( C7_QUANT ) - ( cAliasSC7 )->( C7_QUJE ) ) ,;
							 0 , 0 )
				         
	//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
				
				
			EndIf

		EndIf
	
	   ( cAliasSC7 )->( DbSkip() ) 					     
		   
	EndDo
                  
	( cAliasSC7 )->( dbCloseArea() ) 


	&& Levanta quantidade vendida no ano, se teve venda no ano cria registro com quantidade 0
/*	cQuery    := "SELECT * "
	cQuery    += "FROM "+RetSqlName("SC7")+" SC7 "
	cQuery    += "WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
//	cQuery    += "SC7.C7_PRODUTO='"+SB1->B1_COD+"' AND "
	cQuery    += "SC7.C7_EMISSAO BETWEEN '"+ Dtos(dDataIni) +"' AND '"+DTOS(dDataFin)+"' AND "
	cQuery    += "SC7.C7_QUANT > SC7.C7_QUJE AND "
	cQuery    += "SC7.C7_FORNECE='"+VE4->VE4_CODFOR+"' AND "
	cQuery    += "SC7.C7_LOJA='"+VE4->VE4_LOJFOR+"' AND "
	cQuery    += "SC7.D_E_L_E_T_=' ' AND "

	cQuery    += "SC7.C7_PRODUTO IN "					
	cQuery    += "( SELECT B1_COD "
	cQuery    += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery    += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
	cQuery    += "SB1.B1_AUTGIRO='1' AND "
	cQuery    += "SB1.D_E_L_E_T_=' ' AND "

	cQuery    += "SB1.B1_GRUPO IN "
	cQuery    += "( SELECT BM_GRUPO "
	cQuery    += "FROM "+RetSqlName("SBM")+" SBM "
	cQuery    += "WHERE SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery    += "SBM.BM_PROORI='1' AND "
	cQuery    += "SBM.D_E_L_E_T_=' ' ) ) AND "

	cQuery    += "SC7.C7_NUM IN "
	cQuery    += "( SELECT VEI_NUM "
	cQuery    += "FROM "+RetSqlName("VEI")+" VEI "
	cQuery    += "WHERE VEI.VEI_FILIAL='"+xFilial("VEI")+"' AND "
	cQuery    += "( VEI.VEI_TIPPED='01'OR VEI.VEI_TIPPED='03' ) AND "
	cQuery    += "VEI.D_E_L_E_T_=' ' ) "


	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSC7, .F., .T. ) 

	Do While !( cAliasSC7 )->( Eof() ) 

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + ( cAliasSC7 )->( C7_PRODUTO ) )

		If ( VE4->VE4_PREFAB # FG_MARCA("CHEVROLET",,.f.) .Or. Len(Alltrim( SB1->B1_CODITE )) == 8 )

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
		                         
			FS_GRVVIW(SB1->B1_GRUPO,;
						 SB1->B1_CODITE,;
						 SB2->B2_QATU,;
						 0,;
						 0, 0 )
			         
//			cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer			
			
			
		EndIf
	
	   ( cAliasSC7 )->( DbSkip() ) 					     
		   
	EndDo
                  
	( cAliasSC7 )->( dbCloseArea() ) 
*/

End Transaction

If !Empty(cRecInt)
	// OFIIA200(2,MV_PAR01,GetNewPar("MV_IIA350","021"),"StrZero(VIW->(Recno()),10) $ cRecInt",,,,.f.)
Else	
	If !lAuto
	   MSGSTOP(STR0005) //Processo de exportacao concluido
	EndIf	
EndIf	

Return


Static Function FS_GRVVIW(cGruIte,cCodIte,nQtdEst,nQtdPed,nQtdVen,nQtdPer)
               
DbSelectArea("VIW")
DbSetOrder(1)
DbSeek( xFilial("VIW") + MV_PAR01 + Dtos(dDataBase) + cGruIte + cCodIte )
             
RecLock("VIW",!Found())
VIW->VIW_FILIAL := xFilial("VIW")
VIW->VIW_CODMAR := MV_PAR01
VIW->VIW_DATPRO := dDataBase
VIW->VIW_GRUITE := cGruIte
VIW->VIW_CODITE := cCodIte
VIW->VIW_SINAL  := If(nQtdEst < 0,"-","+")
If !Found()
	VIW->VIW_QTDDIS += nQtdEst
EndIf	
VIW->VIW_QTDPED += nQtdPed
VIW->VIW_QTDVEN += nQtdVen
VIW->VIW_QTDPER += nQtdPer                 
MsUnLock()

cRecInt += StrZero(VIW->(Recno()),10)+"/"
      
Return
