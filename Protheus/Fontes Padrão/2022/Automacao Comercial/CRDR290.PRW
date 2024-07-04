#INCLUDE "REPORT.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDR290.CH"


Static cAlias1	:= ""	// Pega o proximo Alias Disponivel  
Static cCartao	:= ""  //  Numero do cartao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CRDR290   ³ Autor ³ Leandro Nogueira	    ³ Data ³ 29/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de posicao de cartao fidelidade					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=CRDR290(cExp1)			 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL					   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 

Function CRDR290(cNumCar)

Local oReport	        

Default cNumCar := ""

cCartao := cNumCar

cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina disponivel a partir do Release 11.5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetRpoRelease("R5")   
	Return NIL
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("TRepInUse") .OR. TRepInUse()
	oReport:= CRDR290Def(cNumCar) 
	oReport:PrintDialog() 
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CRDR290Def³ Autor ³ Leandro Nogueira	    ³ Data ³ 29/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicoes do relatorio de posicao de cartao fidelidade	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=CRDR290Def()				 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL					   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 
Function CRDR290Def()
Local oReport						//Objeto relatorio TReport (Release 4)
Local oSection1						// Objeto da secao 1	 
Local oSection2						// Objeto da secao 2	
Local oSection3						// Objeto da secao 3

oReport := TReport():New("CRDR290",STR0001,"CRDR290",{|oReport| CRDR290RPT( oReport)},STR0001  )//"Posição do cartão fidelidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Dados Cadastrais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New( oReport,STR0002,{ "MBO","MAM","SLJ","SAE"} )//"Dados Cadastrais"
oSection1:SetLineStyle() 
oSection1:SetHeaderBreak(.T.) 
TRCell():New(oSection1,"MBO_CODBAR"	,"MBO",STR0003+Space(22-Len(STR0003))+".",,60,,,"LEFT")//"Número do Cartão"

#IFDEF TOP
	TRCell():New(oSection1,"MBO_ADMFIN"	,"MBO",STR0020+Space(22-Len(STR0020))+".",,60,,{ || Rtrim((cAlias1)->MBO_ADMFIN) + ' - ' + Rtrim((cAlias1)->AE_DESC) },"LEFT")//"Adm.Financeira"     
	TRCell():New(oSection1,"MBO_CARREF"	,"MBO",STR0004+Space(22-Len(STR0004))+".",,60,,{||Rtrim((cAlias1)->MBO_CARREF) + ' - ' + Rtrim((cAlias1)->MAM_DESC)},"LEFT")//"Cartão Referência"
	TRCell():New(oSection1,"MBO_LOJA"	,"MBO",STR0005+Space(22-Len(STR0005))+".",,60,,{||Rtrim((cAlias1)->MBO_LOJA) + ' - ' + Rtrim((cAlias1)->LJ_NOME)},"LEFT")//"Loja Emissora"
	TRCell():New(oSection1,"MBO_ATIVO"	,"MBO",STR0006+Space(22-Len(STR0006))+".",,60,,{ || Iif((cAlias1)->MBO_ATIVO=="1",STR0007,STR0008)},"LEFT")//"Status"#"Ativo"#"Inativo"                   
#ELSE
	TRCell():New(oSection1,"MBO_ADMFIN"	,"MBO",STR0020+Space(22-Len(STR0020))+".",,60,,{ || Rtrim(("MBO")->MBO_ADMFIN) + ' - ' + Rtrim(("SAE")->AE_DESC) },"LEFT")    
	TRCell():New(oSection1,"MBO_CARREF"	,"MBO",STR0004+Space(22-Len(STR0004))+".",,60,,{||Rtrim(("MBO")->MBO_CARREF) + ' - ' + Rtrim(("MAM")->MAM_DESC)},"LEFT")//"Cartão Referência"
	TRCell():New(oSection1,"MBO_LOJA"	,"MBO",STR0005+Space(22-Len(STR0005))+".",,60,,{||Rtrim(("MBO")->MBO_LOJA) + ' - ' + Rtrim(("SLJ")->LJ_NOME)},"LEFT")//"Loja Emissora"
	TRCell():New(oSection1,"MBO_ATIVO"	,"MBO",STR0006+Space(22-Len(STR0006))+".",,60,,{ || Iif(("MBO")->MBO_ATIVO=="1",STR0007,STR0008)},"LEFT")//"Status"#"Ativo"#"Inativo"                  

#ENDIF
TRCell():New(oSection1,"MBO_DATA"	,"MBO",STR0009+Space(22-Len(STR0009))+".",,60,,,"LEFT")//"Data Cadastro"
TRCell():New(oSection1,"MBO_DTVAL"	,"MBO",STR0010+Space(22-Len(STR0010))+".",,60,,,"LEFT")//"Validade"

oSection1:PrintLine()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Recargas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:= TRSection():New( oSection1,STR0012,{ "MBP"} )//"Recargas"
oSection2:SetLineStyle() 
                                                                       
TRCell():New(oSection2,"MBP_ITEM"	,"MBP",STR0011,,10,,,"LEFT")//"Recarga"
TRCell():New(oSection2,"MBP_DATA"	,"MBP",,,15,,,"LEFT")    
TRCell():New(oSection2,"MBP_DTVAL"	,"MBP",,,15,,,"LEFT")
TRCell():New(oSection2,"MBP_VALOR"	,"MBP",STR0013,,15,,,"LEFT")//"Valor Recarga"
TRCell():New(oSection2,"MBP_SALDO"	,"MBP",STR0014,,15,,,"LEFT")//"Saldo disponível"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3 - Movimentos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New( oSection2,STR0015,{ "MBN"} )//"Vendas"

TRCell():New(oSection3,"MBN_DATA"	,"MBN",STR0016,,30,,,"LEFT")//"Data Venda"    
TRCell():New(oSection3,"MBN_LOJA"	,"MBN",,,,,,"LEFT")
#IFDEF TOP
	TRCell():New(oSection3,"MBN_DOC","MBN",STR0017,,50,,{||Rtrim((cAlias1)->MBN_DOC) + '/' + Rtrim((cAlias1)->MBN_SERIE) },"LEFT")//"Doc. Fiscal"
#ELSE
	TRCell():New(oSection3,"MBN_DOC","MBN",STR0017,,50,,{||Rtrim(("MBN")->MBN_DOC) + '/' + Rtrim(("MBN")->MBN_SERIE) },"LEFT")//"Doc. Fiscal"
#ENDIF
TRCell():New(oSection3,"MBN_VALOR"	,"MBN",STR0018,,20,,,"RIGHT")//"Valor Venda"


TRFunction():New(oSection2:Cell("MBP_VALOR"),NIL,"SUM",,STR0012,,,.F.)//"Recargas"  
TRFunction():New(oSection2:Cell("MBP_SALDO"),NIL,"SUM",,STR0019,,,.F.)//"Saldo" 
TRFunction():New(oSection3:Cell("MBN_VALOR"),NIL,"SUM",,STR0015,,,.F.)//"Vendas"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

                   
Return(oReport) 
Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRDR290RPT   ³ Autor ³Leandro Nogueira    ³ Data ³29/12/2010³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDR290RPT (oReport)
Local oSection1 := oReport:Section(1) 							//Define a secao 1 do relatorio        
Local oSection2 := oReport:Section(1):Section(1)	   			//Define que a secao 2 sera filha da secao 1 
Local oSection3 := oReport:Section(1):Section(1):Section(1)	//Define que a secao 3 sera filha da secao 1
Local cFiltro	:= ""   										//String contendo o filtro de busca.

MakeSqlExpr("CRDR290") 

#IFDEF TOP   
	
	cFiltro := 	" MBO_CODBAR = '" + cCartao + "' "            
	
	cFiltro := "%"+cFiltro+"%"
	
	
   		BEGIN REPORT QUERY oSection1
			BeginSQL alias cAlias1                          	
			SELECT MBO_CODBAR,
					MBO_ADMFIN,
					AE_DESC,
					MBO_CARREF,
					MAM_DESC,
					MBO_LOJA,
					LJ_NOME,
					MBO_ATIVO,
					MBO_DATA,
					MBO_DTVAL,
					MBP_NUMCAR,
					MBP_ITEM,
					MBP_DATA,    
					MBP_DTVAL,
					MBP_VALOR,   
					MBP_SALDO,
					MBN_NUMCAR,
					MBN_SEQ,
					MBN_DATA,
					MBN_LOJA,
					MBN_DOC,
					MBN_SERIE,
					MBN_VALOR,
					MBN_ITSALD									 
		    FROM %table:MBO% MBO
		    		LEFT JOIN %table:SAE% SAE ON 	SAE.AE_COD = MBO.MBO_ADMFIN AND SAE.D_E_L_E_T_= ' '
		    		LEFT JOIN %table:MAM% MAM ON 	MAM.MAM_CODIGO = MBO.MBO_CARREF AND MAM.D_E_L_E_T_= ' '
		    		LEFT JOIN %table:SLJ% SLJ ON 	SLJ.LJ_CODIGO = MBO.MBO_LOJA AND SLJ.D_E_L_E_T_= ' '
		    		LEFT JOIN %table:MBP% MBP ON 	MBP.MBP_NUMCAR = MBO.MBO_CODBAR AND MBP.D_E_L_E_T_= ' ' 
		    		LEFT JOIN %table:MBN% MBN ON 	MBN.MBN_NUMCAR = MBP.MBP_NUMCAR AND 	    		
													MBN.MBN_ITSALD = MBP.MBP_ITEM AND
							 						MBN_TIPMOT= '2' AND
							 						MBN.D_E_L_E_T_= ' '
		
		    	   
		    WHERE	MBO.%notDel% AND  %Exp:cFiltro%  
		    ORDER BY MBN.MBN_ITSALD,MBN.MBN_SEQ
		  		   		   
		EndSql
	END REPORT QUERY oSection1 	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { ||	(cAlias1)->MBP_NUMCAR == (cAlias1)->MBO_CODBAR },	{|| (cAlias1)->MBO_CODBAR}  )
	
	oSection3:SetParentQuery()
	oSection3:SetParentFilter( { | cParam |	(cAlias1)->MBN_NUMCAR+(cAlias1)->MBN_ITSALD == cParam},;
											{|| (cAlias1)->MBP_NUMCAR+(cAlias1)->MBP_ITEM } )										
	                                   
	
#ELSE 
	   
	
	cFiltro := "MBO_CODBAR == '" + cCartao + "' "
	
	oSection1:SetFilter( cFiltro )	     
	
	DbSelectArea("MBO")
	DbSetOrder(1)   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona nas tabelas secundarias usadas na secao1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRPosition():New(oSection1,"MAM",1,{|| xFilial("MAM")+MBO->MBO_CARREF }) 
	TRPosition():New(oSection1,"SLJ",1,{|| xFilial("SLJ")+MBO->MBO_LOJA }) 
	TRPosition():New(oSection1,"SAE",1,{|| xFilial("SAE")+MBO->MBO_ADMFIN }) 
	
	oSection1:SetLineCondition( {|| !MBO->(EOF()) } ) 
	
	
										
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a secao2, com o mesmo filtro da secao1.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2:SetRelation({|| xFilial("MBP")+MBO->MBO_CODBAR },"MBP",1,.T.)
	oSection2:SetParentFilter(	{|cParam| MBP_NUMCAR == cParam}, {||MBO->MBO_CODBAR })	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a secao3, com o mesmo filtro da secao1. 											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3:SetRelation({|| xFilial("MBN")+MBP->MBP_NUMCAR+MBP->MBP_ITEM},"MBN",2,.T.)
	oSection3:SetParentFilter( { | cParam |	MBN_NUMCAR+MBN_ITSALD == cParam}, {|| MBP->MBP_NUMCAR+MBP->MBP_ITEM } )
	oSection3:SetLineCondition( {|| MBN->MBN_TIPMOT= '2' } ) 	
	
#ENDIF
	
oSection1:SetEdit(.F.)
oSection1:SetHeaderSection(.T.)	  
oSection1:Print()    

oSection2:SetHeaderSection(.T.)	  
oSection2:Print()  

oSection3:SetHeaderSection(.T.)	  
oSection3:Print()  

Return NIL