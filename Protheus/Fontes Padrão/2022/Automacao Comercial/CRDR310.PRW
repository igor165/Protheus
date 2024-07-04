#INCLUDE "REPORT.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDR310.CH"


Static cAlias1		:= ""	// Pega o proximo Alias Disponivel  
Static cAlias2		:= ""	// Pega o proximo Alias Disponivel  
Static cAlias3		:= ""	// Pega o proximo Alias Disponivel  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CRDR310   ³ Autor ³    Ricardo Bueno	    ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de posicao de cartao fidelidade					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=CRDR310(cExp1)			 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Numero do cartao fidelidade 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL					   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 

Function CRDR310()  
Local oReport	

cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel
cAlias2	:= GetNextAlias()	// Pega o proximo Alias Disponivel
cAlias3	:= GetNextAlias()	// Pega o proximo Alias Disponivel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina disponivel a partir do Release 11.5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetRpoRelease("R5")   
	Return NIL
Endif


#IFDEF TOP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("CRDR310",.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ MV_PAR01          // Cliente De ?   	           		     ³
	//³ MV_PAR02          // Cliente Ate ?                   		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:=CRDR310Def() 
	oReport:PrintDialog() 

#ENDIF

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CRDR310Def³ Autor ³ Ricardo Bueno		    ³ Data ³ 02/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicoes do relatorio de posicao de cartao fidelidade	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=CRDR310Def()				 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL					   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGACRD												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 
Function CRDR310Def()
Local oReport						//Objeto relatorio TReport (Release 4)
Local oSection1						// Objeto da secao 1	 
Local oSection2						// Objeto da secao 2	
Local oSection3						// Objeto da secao 3

oReport := TReport():New("CRDR310",STR0001,"CRDR310",{|oReport| CRDR310RPT( oReport)},STR0001  )//"Posição do cartão fidelidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Dados Cadastrais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New( oReport,STR0002,{ "MBO","MAM","SLJ","SAE","SA1"} )//"Dados Cadastrais"
oSection1:SetLineStyle() 
oSection1:SetHeaderBreak(.T.) 
TRCell():New(oSection1,"MBO_CODCLI"	,"MBO","Cod Cliente .:"+Space(22-Len("Cod Cliente :"))+".",,60,,,"LEFT")//"Cliente"
TRCell():New(oSection1,"A1_NOME"	,"SA1","Nome .:"+Space(22-Len("Nome .:"))+".",,60,,,"LEFT")//"Nome Cliente"
TRCell():New(oSection1,"MBO_CODBAR"	,"MBO",STR0003+Space(22-Len(STR0003))+".",,60,,,"LEFT")//"Número do Cartão"

TRCell():New(oSection1,"MBO_ADMFIN"	,"MBO",STR0020+Space(22-Len(STR0020))+".",,60,,{ || Rtrim((cAlias1)->MBO_ADMFIN) + ' - ' + Rtrim((cAlias1)->AE_DESC) },"LEFT")//"Adm.Financeira"     
TRCell():New(oSection1,"MBO_CARREF"	,"MBO",STR0004+Space(22-Len(STR0004))+".",,60,,{||Rtrim((cAlias1)->MBO_CARREF) + ' - ' + Rtrim((cAlias1)->MAM_DESC)},"LEFT")//"Cartão Referência"
TRCell():New(oSection1,"MBO_LOJA"	,"MBO",STR0005+Space(22-Len(STR0005))+".",,60,,{||Rtrim((cAlias1)->MBO_LOJA) + ' - ' + Rtrim((cAlias1)->LJ_NOME)},"LEFT")//"Loja Emissora"
TRCell():New(oSection1,"MBO_ATIVO"	,"MBO",STR0006+Space(22-Len(STR0006))+".",,60,,{ || Iif((cAlias1)->MBO_ATIVO=="1",STR0007,STR0008)},"LEFT")//"Status"#"Ativo"#"Inativo"                   
TRCell():New(oSection1,"MBO_DATA"	,"MBO",STR0009+Space(22-Len(STR0009))+".",,60,,,"LEFT")//"Data Cadastro"
TRCell():New(oSection1,"MBO_DTVAL"	,"MBO",STR0010+Space(22-Len(STR0010))+".",,60,,,"LEFT")//"Validade"

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
TRCell():New(oSection3,"MBN_DOC","MBN",STR0017,,50,,{||Rtrim((cAlias3)->MBN_DOC) + '/' + Rtrim((cAlias3)->MBN_SERIE) },"LEFT")//"Doc. Fiscal"
TRCell():New(oSection3,"MBN_VALOR"	,"MBN",STR0018,,20,,,"RIGHT")//"Valor Venda"
                   
Return(oReport) 
Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRDR310RPT   ³ Autor ³ Ricardo Bueno      ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDR310RPT (oReport)
Local oSection1 := oReport:Section(1) 							//Define a secao 1 do relatorio        
Local oSection2 := oSection1:Section(1)				   			//Define que a secao 2 sera filha da secao 1 
Local oSection3 := oSection2:Section(1) 						//Define que a secao 3 sera filha da secao 1
Local cFiltro	:= "AND MBO_CODCLI <> '" + Space(TamSx3("MBO_CODCLI")[1]) + "' "   										//String contendo o filtro de busca.

MakeSqlExpr("CRDR310") 

If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cFiltro += 	"AND MBO_CODCLI BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 
Endif

cFiltro := "%"+cFiltro+"%"

BEGIN REPORT QUERY oSection1
	BeginSQL alias cAlias1                          	
	SELECT	MBO_CODCLI,
	        A1_NOME,
			MBO_CODBAR,
			MBO_ADMFIN,
			AE_DESC,
			MBO_CARREF,
			MAM_DESC,
			MBO_LOJA,
			LJ_NOME,
			MBO_ATIVO,
			MBO_DATA,
			MBO_DTVAL	
    FROM %table:MBO% MBO
    		LEFT JOIN %table:SA1% SA1 ON 	SA1.A1_COD = MBO.MBO_CODCLI AND SA1.D_E_L_E_T_= ' '
    		LEFT JOIN %table:SAE% SAE ON 	SAE.AE_COD = MBO.MBO_ADMFIN AND SAE.D_E_L_E_T_= ' '
    		LEFT JOIN %table:MAM% MAM ON 	MAM.MAM_CODIGO = MBO.MBO_CARREF AND MAM.D_E_L_E_T_= ' '
    		LEFT JOIN %table:SLJ% SLJ ON 	SLJ.LJ_CODIGO = MBO.MBO_LOJA AND SLJ.D_E_L_E_T_= ' '    	   
    WHERE	MBO.%notDel% %Exp:cFiltro% 
  	ORDER BY MBO.MBO_CODCLI
	EndSql
END REPORT QUERY oSection1	

BEGIN REPORT QUERY oSection2
	BeginSQL alias cAlias2                          	
	SELECT	MBO_CODCLI,
			MBP_NUMCAR,	       
			MBP_ITEM,
			MBP_DATA,    
			MBP_DTVAL,
			MBP_VALOR,   
			MBP_SALDO												 
    FROM %table:MBO% MBO
    		LEFT JOIN %table:MBP% MBP ON 	MBP.MBP_NUMCAR = MBO.MBO_CODBAR AND MBP.D_E_L_E_T_= ' '     	   
    WHERE	MBO.%notDel%  AND MBO.MBO_CODCLI = %report_param: (cAlias1)-> MBO_CODCLI % 	%Exp:cFiltro%  
  	ORDER BY MBP.MBP_ITEM 		   
	EndSql
END REPORT QUERY oSection2	

BEGIN REPORT QUERY oSection3
	BeginSQL alias cAlias3 
	SELECT	MBO_CODCLI,
			MBP_VALOR, 		        
			MBN_NUMCAR,
			MBN_SEQ,
			MBN_DATA,
			MBN_LOJA,
			MBN_DOC,
			MBN_SERIE,
			MBN_VALOR,
			MBN_ITSALD									 
    FROM %table:MBO% MBO
	   		LEFT JOIN %table:MBP% MBP ON 	MBP.MBP_NUMCAR = MBO.MBO_CODBAR AND MBP.D_E_L_E_T_= ' ' 
	    	LEFT JOIN %table:MBN% MBN ON 	MBN.MBN_NUMCAR = MBP.MBP_NUMCAR AND 	    		
												MBN.MBN_ITSALD = MBP.MBP_ITEM AND
						 						MBN_TIPMOT= '2' AND
						 						MBN.D_E_L_E_T_= ' '
	
	WHERE MBO.%notDel% 
			AND MBO.MBO_CODCLI = %report_param:(cAlias1)-> MBO_CODCLI % 
			AND MBN.MBN_NUMCAR = %report_param:(cAlias2)-> MBP_NUMCAR % 			
			AND MBN.MBN_ITSALD = %report_param:(cAlias2)-> MBP_ITEM % 			
			%Exp:cFiltro%  
		
	ORDER BY MBO.MBO_CODCLI ASC , MBN.MBN_NUMCAR DESC	
	EndSql  	
END REPORT QUERY oSection3	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de impressao³     
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !oReport:Cancel() .AND. (cAlias1)->(!Eof()) //Regra de impressao
	
	//Impressao da secao 1  - Cliente/Cartao
	oSection1:Init() 
	oSection2:ExecSql() 	
		
	If  !(cAlias2)->(Eof()) 
		oSection1:PrintLine()	
	EndIf
	
	//Impressao da secao 2 - Recargas
	While !oReport:Cancel() .And. !(cAlias2)->(Eof())			
		oReport:IncMeter()
		oSection2:Init()			   		
		oReport:SkipLine()			
		oSection2:PrintLine()              				
			
		//Impressao da secao 3 - Movimentos
		oSection3:ExecSql() 		
		While !oReport:Cancel() .And. !(cAlias3)->(Eof())
			oReport:IncMeter()
			oSection3:Init()			   					
			oSection3:PrintLine()				
			(cAlias3)->(DbSkip())	 	 			 				 			
		End	
		oSection3:Finish()				
		(cAlias2)->(DbSkip())
	End
	oSection2:Finish()		 	 			 				 				
	(cAlias1)->(DbSkip())
	oReport:ThinLine()	
End
oSection1:Finish()
Return NIL