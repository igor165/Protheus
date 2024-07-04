#include "protheus.ch"
#include "report.ch"      
#include "GPER107.ch"      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GPER107  ณ Autor ณ Valdeci Lira                    ณ Data ณ 04/03/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Relatorio de Trajetoria Laboral                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ FNC            ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMauricio T. ณ27/04/09ณ00000009879/2009ณNome do Campo de Filial da Tabela SQB estaณฑฑ
ฑฑณ            ณ        ณ                ณva incorreta.                             ณฑฑ
ฑฑณRogerio R.  ณ        ณ00000011317/2009ณAlteracao na declaracao da var cVisaoDeptoณฑฑ
ฑฑณValdeci Liraณ07/03/09ณ00000016697/2009ณAlteracao da Origem do Select no campo    ณฑฑ
ฑฑณ            ณ        ณ                ณvirtual para a tabela RCP, criado na Queryณฑฑ
ฑฑณValdeci Liraณ30/07/09ณ00000018862/2009ณAlteracao do relatorio para que o filtro  ณฑฑ
ฑฑณ            ณ        ณ                ณpor Centro Custo seja respeitado correta- ณฑฑ
ฑฑณ            ณ        ณ                ณmente.                                    ณฑฑ
ฑฑณMarcelo     ณ14/10/09ณ00000024523/2009ณAjustes para correcao de campos definidos ณฑฑ
ฑฑณ            ณ        ณ                ณna query e impressao dos movimentos A, B eณฑฑ
ฑฑณ            ณ        ณ                ณC conforme os parametros.                 ณฑฑ
ฑฑณFrancisco Jrณ03/02/10ณ00000002364/2010ณCompatibilizado o fonte para uso na Ges-  ณฑฑ
ฑฑณ            ณ        ณ                ณtao Corporativa.                          ณฑฑ
ฑฑณClaudinei S.ณ04/07/12ณ00000015763/2012ณCompatibilizado o fonte para uso na Ges-  ณฑฑ
ฑฑณ            ณ        ณ          TFEWP0ณtao Corporativa.                          ณฑฑ
ฑฑณAdemar Jr.  ณ17/11/12ณRequisito:      ณBRA-Utilizacao do mv_par10 em cCodDepto,  ณฑฑ
ฑฑณ            ณ        ณRHU210          ณ independente do MV_ORGCFG.               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function GPER107()

	Local 	aArea	:= GetArea()         												  //-> Guarda a Area de Trabalho atual	
	Local 	oReport																		  //-> Objeto do relatorio
	Private cAliasQry																	  //-> Variavel para abertura da query no Top 
	Private	cQryPto   := ""																  //-> Armazena a Query que serve somente de ponteiro p/ imp da Traj	
	Private	cAliasPto := ""																  //-> Armazena o Alias para o resultset da QueryPto	
	Private aOrd	:={	OemToAnsi(STR0002)+"+"+OemToAnsi(STR0001)						,;//1-"Centro Custo	+ Trajetoria"	
						OemToAnsi(STR0003)+"+"+OemToAnsi(STR0001)						,;//2-"Departamento	+ Trajetoria"
						OemToAnsi(STR0002)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0001),;//3-"Centro Custo + Departamento + Trajetoria"
						OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0001),;//4-"Centro Custo	+ Funcao 	   + Trajetoria"
						OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0001),;//5-"Departamento	+ Funcao 	   + Trajetoria"
						OemToAnsi(STR0002)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0001),;//6-"Centro Custo+Departamento+Funcao+Trajetoria"
						OemToAnsi(STR0005)+"+"+OemToAnsi(STR0001)						};//7-"Registro Patronal+Trajetoria"
	                                                    
	Private lUsaArqui	:= Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos.
	Private cVisaoDepto:= ""
	
	//Insere perguntes no SX1 caso  nao tenha

	
	Pergunte("GPE107R",.F.)    
	
	If FindFunction("TRepInUse") .And. TRepInUse()                     '
	    oReport := ReportDef()
	    oReport:PrintDialog() 
	EndIF    
	
	RestArea( aArea )	//-> Retorna a Area de Trabalho Atual							
Return Nil

     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณValdeci Lira        บ Data ณ  04/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao do Relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()
 
	Local oReport          	//->Objeto para Definicao do Relatorio              
	Local oSctTraj			//->Objeto para Definicao da Section de Funcionarios     
	Local oSctFnc			//->Objeto para Definicao da Section de Funcionarios
	Local oSctRCP			//->Objeto para Definicao da Section de Movimentacao[RCP]
	Local oSctSRE			//->Objeto para Definicao da Section de Movimentacao[SRE]
	Local oSctSR8			//->Objeto para Definicao da Section de Movimentacao[SR8]
	Local oSctCCusto		//->Objeto para Definicao da Section Centro de Custo
	Local oSctDepartamento	//->Objeto para Definicao da Section Departamento
	Local oSctFuncao		//->Objeto para Definicao da Section Funcao 
	Local oSctRegPatronal	//->Objeto para Definicao da Section RegPatronal

	Private cTitulo	:= OemtoAnsi(STR0006)
	                                
	/*					   | Nome Rel |	Titulo|	Perguntes |	Action, qdo Apertar o Ok	  | Descricao         | 														*/
    oReport:=TReport():New( "GPER107", cTitulo, "GPE107R", {|oReport| RelFuncImp(oReport)}, OemToAnsi(STR0007))                                                                             
	
	//Propriedades
	oReport:nFontBody:= 8
	oReport:SetDynamic()  
	
	//Section Oca para impressao da section FNC, RCP, SRE e SR8, pela funcao fImpTrajLab                                                                           
	oSctTraj:= TRSection():New( oReport, "", , aOrd, Nil, Nil)          
	oSctTraj:SetDynamicKey(OemToAnsi(STR0001)) 
	
	//Section 2, Funcionario		
	oSctFnc := TRSection():New( oReport, OemToAnsi(STR0007), "SRA" , aOrd, Nil, Nil) 
	TRCell():New( oSctFnc, "RA_FILIAL" , "SRA", , , , ,{|| (cAliasQry)->Ra_Filial})
	TRCell():New( oSctFnc, "RA_MAT"	   , "SRA", , , , ,{||(cAliasQry)->Ra_Mat })
	TRCell():New( oSctFnc, "RA_NOME"   , "SRA", , , , ,{||(cAliasQry)->Ra_Nome})
	TRCell():New( oSctFnc, "RA_ADMISSA", "SRA", , , , ,{||(cAliasQry)->Ra_Admissa})
	TRCell():New( oSctFnc, "RA_DDEPTO" , "SRA","Depto", , , ,{||(cAliasQry)->Ra_Depto+" - "+(cAliasQry)->Ra_DDepto})
	TRCell():New( oSctFnc, "RA_SALMES" , "SRA", , , , ,{||(cAliasQry)->Ra_SalMes}) 
	oSctFnc:Cell("RA_ADMISSA"):SetCellBreak()	  		    
	oSctFnc:SetLineStyle()	  
	
	//Section 3, Trajetoria
	oSctRCP := TRSection():New( oReport, OemToAnsi(STR0008), "RCP" , aOrd, Nil, Nil)
	TRCell():New( oSctRCP, "RCP_DTMOV"	 , "RCP",,,,,{|| (cAliasQry)->DataMov})
	TRCell():New( oSctRCP, "RCP_TPMOV"	 , "RCP",,"@!",15,,{|| fDescTpMov((cAliasQry)->Tipo)})
	TRCell():New( oSctRCP, "RCP_SALMES"  , "RCP",,,,,{|| (cAliasQry)->Rcp_SalMes})
	TRCell():New( oSctRCP, "RCP_SALDII"  , "RCP",,,,,{|| (cAliasQry)->Rcp_SalDii})

	oSctRCP:CELL("RCP_DTMOV") :SetAlign("LEFT")
	oSctRCP:CELL("RCP_TPMOV") :SetAlign("LEFT")
	oSctRCP:CELL("RCP_SALMES"):SetAlign("LEFT")
	oSctRCP:CELL("RCP_SALDII"):SetAlign("LEFT")
	//Tipos de Movimentacao
	//01=Admissao;02=Baixa IMSS;03=Alta Reg.Patr.;04=Baixa Reg.Patr.;05=Modif.Sal.;
	//06=Reingresso;07=Alta Esp. Infonavit;20=Baixa Folha					
	
	//Section 4, Transferencias 
	oSctSRE := TRSection():New( oReport, OemToAnsi(STR0009), "SRE" , aOrd, Nil, Nil)
	TRCell():New( oSctSRE, "RE_DATA"	, "SRE")
	TRCell():New( oSctSRE, "ORIGEM"		, ""   , OemToAnsi(STR0011), "@!")		
	TRCell():New( oSctSRE, "RE_EMPD"	, "SRE")
	TRCell():New( oSctSRE, "RE_FILIALD"	, "SRE")
	TRCell():New( oSctSRE, "RE_MATD"	, "SRE")
	TRCell():New( oSctSRE, "RE_CCD" 	, "SRE")
	TRCell():New( oSctSRE, "RE_PROCESD"	, "SRE")
	TRCell():New( oSctSRE, "DESTINO"	, ""   , OemToAnsi(STR0012), "@!")
	TRCell():New( oSctSRE, "RE_EMPP"	, "SRE")
	TRCell():New( oSctSRE, "RE_FILIALP"	, "SRE")
	TRCell():New( oSctSRE, "RE_MATP"	, "SRE")
	TRCell():New( oSctSRE, "RE_CCP" 	, "SRE")
	TRCell():New( oSctSRE, "RE_PROCESP"	, "SRE")                                                                                                                      
	
	oSctSRE:SetLineStyle()
	oSctSRE:CELL("RE_DATA"):SetCellBreak()
	oSctSRE:CELL("ORIGEM"):SetCellBreak()
	oSctSRE:CELL("RE_PROCESD"):SetCellBreak()
	oSctSRE:CELL("DESTINO"):SetCellBreak()
    	  
	//Section 5, Afastamentos
	oSctSr8:= TRSection():New( oReport, OemToAnsi(STR0010), "SR8,RCM" , aOrd, Nil, Nil)
	TRCell():New( oSctSr8, "R8_DATAINI", "SR8")
	TRCell():New( oSctSr8, "R8_TIPOAFA", "SR8", , "@!", 25)//FK_RCM
	TRCell():New( oSctSr8, "R8_DURACAO", "SR8")
	
	//Section 6, Centro de Custo	
	oSctCCusto:= TRSection():New( oReport, OemToAnsi(STR0002), "" , aOrd, Nil, Nil)
	TRCell():New( oSctCCusto, "CTT_FILIAL", "", , , , , {|| (cAliasQry)->Ctt_Filial})
	TRCell():New( oSctCCusto, "CTT_CUSTO" , "", , , , , {|| (cAliasQry)->Ctt_Custo })
	TRCell():New( oSctCCusto, "CTT_DESC01", "", , , , , {|| (cAliasQry)->Ctt_Desc01})				
	oSctCCusto:Disable() 
	oSctCCusto:SetLineStyle()                         
	oSctCCusto:SetDynamicKey(OemToAnsi(STR0002))	
	
	//Section 7, Departamentos
	oSctDepartamento := TRSection():New( oReport,, "SQB" , aOrd, Nil, Nil)
	TRCell():New( oSctDepartamento, "QB_FILIAL", "SQB" , , , , , {|| (cAliasQry)->Qb_Filial})
	TRCell():New( oSctDepartamento, "QB_DEPTO" , "SQB" , , , , , {|| (cAliasQry)->Qb_Depto })
	TRCell():New( oSctDepartamento, "QB_DESCRIC", "SQB", , , , , {|| (cAliasQry)->Qb_Descric})				
	oSctDepartamento:Disable() 
	oSctDepartamento:SetLineStyle()                         
	oSctDepartamento:SetDynamicKey(OemToAnsi(STR0003))						
    
    //Section 8, Funcao	
	oSctFuncao:= TRSection():New( oReport, OemToAnsi(STR0004), "SRJ" , aOrd, Nil, Nil)
	TRCell():New( oSctFuncao, "RJ_FILIAL", "SRJ", , , , , {|| (cAliasQry)->Rj_Filial})
	TRCell():New( oSctFuncao, "RJ_FUNCAO", "SRJ", , , , , {|| (cAliasQry)->Rj_Funcao })
	TRCell():New( oSctFuncao, "RJ_DESC"	 , "SRJ", , , , , {|| (cAliasQry)->Rj_Desc})				
	oSctFuncao:Disable() 
	oSctFuncao:SetLineStyle()                         
	oSctFuncao:SetDynamicKey(OemToAnsi(STR0004))
    
	//Section 9, Registro Patronal
	oSctRegPatronal:= TRSection():New( oReport, OemToAnsi(STR0004), "RCO" , aOrd, Nil, Nil)
	TRCell():New( oSctRegPatronal, "RCO_CODIGO", "RCO", , , , , {|| (cAliasQry)->Rco_Codigo})
	TRCell():New( oSctRegPatronal, "RCO_NREPAT", "RCO", , , , , {|| (cAliasQry)->Rco_NREPAT})
	TRCell():New( oSctRegPatronal, "RCO_NOME"  , "RCO", , , , , {|| (cAliasQry)->Rco_Nome})				
	oSctRegPatronal:Disable() 
	oSctRegPatronal:SetLineStyle()                         
	oSctRegPatronal:SetDynamicKey(OemToAnsi(STR0005))  
	
	//Section 10, Header
	DEFINE SECTION oSectionh OF oReport TITLE OemToAnsi(STR0022) TABLE "SRA" ORDERS aOrd	PAGE HEADER	//Processo / Periodo

	DEFINE CELL NAME "ARQORG"  OF oSectionh TITLE OemToAnsi(STR0022) SIZE 125		//"Arquitetura Organizacional - " 
	oSectionh:SetLineStyle()   
				
Return( oReport )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRelFuncImpบAutor  ณValdeci Lira        บData  ณ  04/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de Impressao do Relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RelFuncImp(oReport)    
	Local nOrdem 	 		:= ""	//->Armazena a ordem digitada pelo funcionario 
	Local cJoinAdicional	:= "%%" //->Possiveis Joins Adicionais dependendo da ordem de quebra selecionada
	Local cCamposAdicionais	:= "%%" //->Campos adicionais para complementar a query, dependendo da ordem de quebra selecionada
	Local cModCCTT			:= ""   //->Verifica o modo de compartilhamento da tabela, para definir join 
	Local cModCSQB          := ""   //->Verifica o modo de compartilhamento da tabela, para definir join 
	Local cModCSRJ          := ""   //->Verifica o modo de compartilhamento da tabela, para definir join 
	Local cModCSRE          := ""   //->Verifica o modo de compartilhamento da tabela, para definir join 
	Local cModCRCO          := ""   //->Verifica o modo de compartilhamento da tabela, para definir join 
	Local cMCSqbSql        	:= ""   //->Variavel de modo de compartilhamento do Sqb para o BeginSql
	Local cFilPerg					//->Filial informada na pergunta
	Local cCCustoP					//->Centro de Custo Informado na Pergunta
	Local cMatPerg					//->Matricula informado na pergunta
	Local cSituacao 				//->Situacao do Funcionario informado na pergunta
	Local cCategoria				//->Categoria do Funcionario informado na pergunta
	Local cSitQuery			:= ""	//->Situacao do Funcionario informado na pergunta, ja tratada para query
	Local cCatQuery			:= ""   //->Categoria do Funcionario informado na pergunta, ja tratada para query
	Local cOpcRelat 				//->Opcoes de movimentacao da trajetoria laboral informada na pergunta
	Local cDataDe					//->Data de inicio, usada no filtro da query, informada na pergunta
	Local cDataAte					//->Data fim, usada no filtro da query, informada na pergunta
	Local cDtMov                    //->Data de movimentacao usada para filtro da query, resultante da DataDe-DataAte
	Local nReg						//->Usado no For para quebra de Situacao e Categoria				    
	Local lRCP01					//->Inclui tipo de movimentacao 1? Informado nas perguntas
	Local lRCP02					//->Inclui tipo de movimentacao 2? Informado nas perguntas
	Local lRCP03					//->Inclui tipo de movimentacao 3? Informado nas perguntas
	Local lRCP04					//->Inclui tipo de movimentacao 4? Informado nas perguntas
	Local lRCP05					//->Inclui tipo de movimentacao 5? Informado nas perguntas
	Local lRCP06					//->Inclui tipo de movimentacao 6? Informado nas perguntas
	Local lRCP07					//->Inclui tipo de movimentacao 7? Informado nas perguntas
	Local lRCP20					//->Inclui tipo de movimentacao 20? Informado nas perguntas
	Local lShar
	Local cSSR8                     //->Armazena a query para a tabela SR8
	Local cSSRE      				//->Para montagem do SQL para select do SRE
	Local cChaveArq
	Local cOrgJoin	:= ""
	Local cWSR8						//->Armazena a clausula where para SR8
	Local cWRCP						//->Armazena a clausula where para a RCP
	Local cWSRE						//->Para montagem da clausula Where do SRE
	Local cUnion					//->Para uniao de sre e sr8 e where rcp, conforme necessidade
	Local oSctTraj					//->Objeto para Definicao da Section de Funcionarios
	Local oSctCCusto	 			//->Objeto para Definicao da Section Centro de Custo
	Local oSctDepartamento 			//->Objeto para Definicao da Section Departamento
	Local oSctFuncao				//->Objeto para Definicao da Section Funcao 
	Local oSctRegPatronal			//->Objeto para Definicao da Section RegPatronal  
	Local oSectionH	:= oReport:Section(10)  
	Local lUsaArqui := Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos. 
	Local aChaveArq	:= {}

	Private cModCSRV	 := ""   	//->Verifica o modo de compartilhamento da tabela para impressao  da trajetoria laboral
	Private lOpcAfast				//->Inclui Afastamentos? Informado nas perguntas
	Private lOpcFerias				//->Inclui Ferias? Informado nas perguntas
	Private lOpcTransf  			//->Inclui Transferencias? Informado nas perguntas	
	Private cCodVisao
	Private cCodDepto
	Private oSctFnc					//->Section do Funcionario
	Private oSctRcp					//->Section da Traj Laboral
	Private oSctSre					//->Section de Transferencias
	Private oSctSr8					//->Section de Afastamentos
	Private bImpTrajLab		:= {|| }//->Condicao para impressao da trajetoria laboral

	cCodDepto	:= mv_par10
	If lUsaArqui 	//Se uas Arquitetura Organizadional (SIGAORG)
		cCodVisao	:= mv_par09
//-		cCodDepto	:= mv_par10
	Else
		cCodVisao	:= ""
//-		cCodDepto	:= ""
	EndIf  
              
	If !Empty(cCodVisao + cCodDepto)
	   	aChaveArq	:= fQueryVisao()                           
		cChaveArq	:= aChaveArq[2]
		lShar		:= Iif(Empty(aChaveArq[1]),.T.,.F.)
		cOrgJoin	:= " INNER JOIN (SELECT RD4.RD4_FILIDE, RD4.RD4_CODIDE, RD4.RD4_CHAVE "
		cOrgJoin	+= " FROM " + RetSqlName("RD4") + " RD4 "
		cOrgJoin	+= " WHERE RD4_CHAVE LIKE '" + AllTrim(cChaveArq) + "%' AND RD4.D_E_L_E_T_ <> '*' ) TVRD4 "
		cOrgJoin	+= " ON RA_DEPTO = TVRD4.RD4_CODIDE "
		If !lShar
			cOrgJoin+= " AND RA_FILIAL = TVRD4.RD4_FILIDE "
		EndIf 
		
		cVisaoDepto	:=	OemToAnsi(STR0023) + AllTrim(cCodVisao) + " / " + 	;	//"Visใo: "
						OemToAnsi(STR0003) + AllTrim(cCodDepto)										//"Depto.: "  	
						
		oReport:OnPageBreak({||	oSectionh:Init(), oSectionH:Cell("ARQORG"):SetValue(cVisaoDepto), oSectionh:PrintLine(), oSectionh:Finish(), oReport:ThinLine()})	
	EndIf
	
		//Descobre compartilhamento das tabelas usadas    
		Sx2ChkModo( "CTT", NIL, .F., @cModCCTT, NIL )
		Sx2ChkModo( "SQB", NIL, .F., @cModCSQB, NIL )
		Sx2ChkModo( "SRJ", NIL, .F., @cModCSRJ, NIL )
		Sx2ChkModo( "SRE", NIL, .F., @cModCSRE, NIL )
		Sx2ChkModo( "RCO", NIL, .F., @cModCRCO, NIL )
		Sx2ChkModo( "SRV", NIL, .F., @cModCSRV, NIL )		
		
		iIf( cModCCTT == "E" , cModCCTT := " CTT_FILIAL=FILD AND " , cModCCTT := "")
		iIf( cModCSQB == "E" , cModCSQB := " QB_FILIAL=FILD AND " , cModCSQB := "")
		iIf( cModCSRJ == "E" , cModCSRJ := " RJ_FILIAL=FILD AND " , cModCSRJ := "")
		iIf( cModCSRE == "E" , cModCSRE := " RE_FILIAL=FILD AND " , cModCSRE := "")
		iIf( cModCRCO == "E" , cModCRCO := " RCO_FILIAL=FILD AND " , cModCRCO := "")
		
		nOrdem := oReport:GetOrder()
		//Section Trajetoria
	   	oSctTraj  	:= oReport:Section(1)  	        
		oSctFnc  	:= oReport:Section(2)  
		oSctRcp		:= oReport:Section(3)  					
		oSctSre		:= oReport:Section(4)  
		oSctSr8 	:= oReport:Section(5) 
	
		Do Case 
			Case nOrdem == 1                     
				oSctCCusto	:= oReport:Section(6) 
				oSctCCusto	:Enable()
		        oSctCCusto	:SetLeftMargin(3)    
				oSctFnc		:SetLeftMargin(5)
				oSctRcp		:SetLeftMargin(10)
				oSctSre		:SetLeftMargin(15)
				oSctSr8		:SetLeftMargin(20)
				bImpTrajLab:= {|| fImpTrajLaboral("(cAliasQry)->Ra_Filial+(cAliasQry)->Ra_Mat+(cAliasQry)->Ra_CC")}
				cCamposAdicionais	:= "%Ctt_Filial, Ctt_Custo, Ctt_Desc01,%" 
				cJoinAdicional		:= "%Inner Join "+RetSqlName("CTT")+" Ctt On " + cModCCTT + " Ctt_Custo=Ra_CC "+cOrgJoin+"%"
				cOrderBy			:= "%FilD, CTT_Custo, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
				oSctTraj:OnPrintLine(bImpTrajLab)
			Case nOrdem == 2  
				oSctDepartamento	:= oReport:Section(7)			
				oSctDepartamento	:Enable()
		        oSctDepartamento:SetLeftMargin(3) 
				oSctFnc:SetLeftMargin(5)
				oSctRcp:SetLeftMargin(10)
				oSctSre:SetLeftMargin(15)
				oSctSr8:SetLeftMargin(20)                                                                          
				bImpTrajLab:= {|| fImpTrajLaboral("(cAliasQry)->Ra_Filial+(cAliasQry)->Ra_Mat+(cAliasQry)->Ra_Depto")}
				cCamposAdicionais	:= "%Qb_Filial, Qb_Depto, Qb_Descric,%"                                           
				cJoinAdicional		:= "%"+cOrgJoin+"%"
				cOrderBy			:= "%FilD, Qb_Depto, Ra_Depto, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
				oSctTraj:OnPrintLine(bImpTrajLab)
			Case nOrdem == 3 
				oSctCCusto		:= oReport:Section(6)			
				oSctCCusto		:Enable()
				oSctDepartamento:= oReport:Section(7)			
				oSctDepartamento:Enable()                                                                             
	   	   	   	bImpTrajLab:= {|| fImpTrajLaboral("(cAliasPto)->Ra_Filial+(cAliasPto)->Ra_Mat")}
				cCamposAdicionais:= "%Ctt_Filial, Ctt_Custo, Ctt_Desc01,Qb_Filial, Qb_Depto, Qb_Descric,%" 
				cJoinAdicional	 := "%Inner Join "+RetSqlName("CTT")+" Ctt On " + cModCCTT + " Ctt_Custo=Ra_CC "+cOrgJoin+"%"
				cOrderBy    	 := "%FilD, Ctt_Custo, Ra_Depto, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
				oSctCCusto:SetLeftMargin(3)			
				oSctDepartamento:SetLeftMargin(5)
				oSctFnc:SetLeftMargin(10)
				oSctRcp:SetLeftMargin(15)
				oSctSre:SetLeftMargin(20)
				oSctSr8:SetLeftMargin(25) 
						
		  	   	oSctTraj:OnPrintLine(bImpTrajLab)  
			Case nOrdem == 4
				oSctCCusto		:= oReport:Section(6)			
				oSctCCusto		:Enable()
				oSctFuncao		:= oReport:Section(8)			
				oSctFuncao		:Enable()                                                                             
	   	   	   	bImpTrajLab		:= {|| fImpTrajLaboral("(cAliasPto)->Ra_Filial+(cAliasPto)->Ra_Mat")}
				cCamposAdicionais:= "%Ctt_Filial, Ctt_Custo, Ctt_Desc01, Ra_CodFunc, Rj_Filial, Rj_Funcao, Rj_Desc,%" 
				cJoinAdicional	 := "Inner Join "+RetSqlName("CTT")+" Ctt On " + cModCCTT + " Ctt_Custo=Ra_CC "
				cJoinAdicional	 += "Inner Join "+RetSqlName("SRJ")+" Srj On " + cModCSRJ + " Rj_Funcao=Ra_CodFunc"
				cJoinAdicional	 := "%" + cJoinAdicional + cOrgJoin + "%"
				cOrderBy    	 := "%FilD, Ctt_Custo, Rj_Funcao, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
				oSctCCusto:SetLeftMargin(3)			
				oSctFuncao:SetLeftMargin(5)
				oSctFnc:SetLeftMargin(10)
				oSctRcp:SetLeftMargin(15)
				oSctSre:SetLeftMargin(20)
				oSctSr8:SetLeftMargin(25) 					
		  		oSctTraj:OnPrintLine(bImpTrajLab)
			Case nOrdem == 5 
				oSctDepartamento:= oReport:Section(7)			
				oSctDepartamento:Enable()     
				oSctFuncao		:= oReport:Section(8)			
				oSctFuncao		:Enable()
	   	   	   	bImpTrajLab:= {|| fImpTrajLaboral("(cAliasPto)->Ra_Filial+(cAliasPto)->Ra_Mat")}
				cCamposAdicionais:= "%Qb_Filial, Qb_Depto, Qb_Descric, Ra_CodFunc, Rj_Filial, Rj_Funcao, Rj_Desc,%" 
				cJoinAdicional	 := " Inner Join "+RetSqlName("SRJ")+" Srj On " + cModCSRJ + " Rj_Funcao=Ra_CodFunc "
				cJoinAdicional	 := "%" + cJoinAdicional + cOrgJoin + "%"
				cOrderBy    	 := "%FilD, Qb_Depto, Rj_Funcao, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
	   	   		oSctDepartamento:SetLeftMargin(3)			
				oSctFuncao:SetLeftMargin(5)
				oSctFnc:SetLeftMargin(10)
				oSctRcp:SetLeftMargin(15)
				oSctSre:SetLeftMargin(20)
				oSctSr8:SetLeftMargin(25)
				oSctTraj:OnPrintLine(bImpTrajLab)
			Case nOrdem == 6  
				oSctCCusto		:= oReport:Section(6)			
				oSctCCusto		:Enable()
				oSctDepartamento:= oReport:Section(7)			
				oSctDepartamento:Enable()     
				oSctFuncao		:= oReport:Section(8)			
				oSctFuncao		:Enable()  
	   	   	   	bImpTrajLab:= {|| fImpTrajLaboral("(cAliasPto)->Ra_Filial+(cAliasPto)->Ra_Mat")}
				cCamposAdicionais:= "Ctt_Filial, Ctt_Custo, Ctt_Desc01, Ra_CodFunc, Rj_Filial, Rj_Funcao, Rj_Desc," 
	   	   		cCamposAdicionais+= "Qb_Filial, Qb_Depto, Qb_Descric," 
	   	   		cCamposAdicionais:= "%" + cCamposAdicionais + "%"
				cJoinAdicional	 := " Inner Join "+RetSqlName("SRJ")+" Srj On " + cModCSRJ + " Rj_Funcao=Ra_CodFunc "
				cJoinAdicional	 += " Inner Join "+RetSqlName("CTT")+" Ctt On " + cModCCTT + " Ctt_Custo=Ra_CC "
				cJoinAdicional	 := "%" + cJoinAdicional + "%"
				cOrderBy    	 := "%FilD, Ctt_Custo, Qb_Depto, Rj_Funcao, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
	   	   		oSctCCusto:SetLeftMargin(3)			
	   	   		oSctDepartamento:SetLeftMargin(5)			
				oSctFuncao:SetLeftMargin(7)
				oSctFnc:SetLeftMargin(10)
				oSctRcp:SetLeftMargin(15)
				oSctSre:SetLeftMargin(20)
				oSctSr8:SetLeftMargin(25) 
				oSctTraj:OnPrintLine(bImpTrajLab) 
			Case nOrdem == 7
				//Registro Patronal
				oSctRegPatronal	:= oReport:Section(9)			
				oSctRegPatronal	:Enable()
		        oSctRegPatronal	:SetLeftMargin(3)    
				oSctFnc:SetLeftMargin(5)
				oSctRcp:SetLeftMargin(10)
				oSctSre:SetLeftMargin(15)
				oSctSr8:SetLeftMargin(20)
				bImpTrajLab:= {|| fImpTrajLaboral("(cAliasQry)->Ra_Filial+(cAliasQry)->Ra_Mat+(cAliasQry)->Ra_CC")}
				cCamposAdicionais	:= "%RCO_FILIAL, RCO_CODIGO, RCO_NREPAT,RCO_NOME,Ra_CodRPat, %" 
				cJoinAdicional		:= "%Inner Join "+RetSqlName("RCO")+" Rco On " + cModCRCO + " Rco_Codigo=Ra_CodRPat "+cOrgJoin+"%"
				cOrderBy			:= "%FilD, Rco_Codigo, MatD, DataMov, Tipo, CCD, CCP, OrSlct%"
				oSctTraj:OnPrintLine(bImpTrajLab) 
	 	End Case
    
		//SQL
		#IFDEF TOP 
			MakeSqlExpr("GPE107R")
			
			cFilPerg	:= mv_par01
			cCCustoP	:= mv_par02
			cMatPerg	:= mv_par03
			cSituacao   := mv_par04
			cCategoria  := mv_par05
			cOpcRelat   := mv_par06
			cDataDe		:= DToc(mv_par07)
			cDataAte	:= DToc(mv_par08)

			cSitQuery := ""        
			For nReg := 1 to Len(cSituacao)
				cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
			 	If ( nReg+1 ) <= Len(cSituacao)
			  		cSitQuery += "," 
			 	Endif
			Next nReg 
				
			cCatQuery := ""
			For nReg:=1 to Len(cCategoria)
			 cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
			 If ( nReg+1 ) <= Len(cCategoria)
			  cCatQuery += "," 
			 Endif
			Next nReg
			 	
			cRCP01		:= If( "1" $ cOpcRelat, "'01',", "")
			cRCP02		:= If( "2" $ cOpcRelat, "'02',", "")
			cRCP03		:= If( "3" $ cOpcRelat, "'03',", "")
			cRCP04		:= If( "4" $ cOpcRelat, "'04',", "")
			cRCP05		:= If( "5" $ cOpcRelat, "'05',", "")
			cRCP06		:= If( "6" $ cOpcRelat, "'06',", "")
			cRCP07		:= If( "7" $ cOpcRelat, "'07',", "")
			cRCP20		:= If( "8" $ cOpcRelat, "'20',", "")
			lOpcAfast	:= If( "A" $ cOpcRelat, .T., .F.)
			lOpcFerias	:= If( "B" $ cOpcRelat, .T., .F.)
			lOpcTransf	:= If( "C" $ cOpcRelat, .T., .F.)
	
			If !Empty(cDataDe) 
				cDtMov := " DataMov >='"+ dToS(cToD(cDataDe)) + "' "
			EndIf
			If !Empty(cDataDe) 
				If !Empty(cDtMov)
					cDtMov := cDtMov + " AND "
				EndIf
				cDtMov += " DataMov <='"+ dToS(cToD(cDataAte)) + "' "
			EndIf    
			
			If !Empty(cDtMov)                  
				cDtMov := "% AND "+ cDtMov +"%"		
			EndIf
			
			cFilPerg		:= StrTran(StrTran(cFilPerg, "(RA_FILIAL", ""), ")", "") 
			cCCustoPerg		:= StrTran(StrTran(cCCustoP, "(RA_CC", ""), ")", "")
			cMatPerg		:= StrTran(StrTran(cMatPerg, "(RA_MAT", ""), ")", "")
			cOpcRelatPerg	:= StrTran(StrTran(cOpcRelat, "( ", ""), ")", "")
			cSitQuery 		:= "%"+cSitQuery+"%"
			cCatQuery 		:= "%"+cCatQuery+"%"
	
			If At("IN(", cFilPerg) >0 
				cFilPerg := cFilPerg + ")"
			End If        
			If At("IN(", cCCustoPerg) >0 
				cCCustoPerg := cCCustoPerg + ")"
			End If    
			If At("IN(", cMatPerg) >0 
				cMatPerg := cMatPerg + ")"
			End If
			cWRCP := cRCP01+cRCP02+cRCP03+cRCP04+cRCP05+cRCP06+cRCP07+cRCP20		
			cWRCP := If(Len(AllTrim(cWRCP))>0, " AND RCP.RCP_TPMOV IN("+Left(cWRCP,Len(cWRCP)-1)+")", " AND RCP.RCP_TPMOV IN ('00')")
			cWSRE := ""
			cWSR8 := ""
			If !Empty(cFilPerg)        
			    cWRCP	+= " AND (RCP.RCP_FILIAL " + cFilPerg + ") "
	   		    cWSRE	:= If( !Empty(cModCSRE), " AND (A.RE_FILIAL " + cFilPerg + ") ", "" )
	   		    cWSR8	:= " AND (SR8.R8_FILIAL " + cFilPerg + ") " 
			EndIf                      
			
			If !Empty(cMatPerg)                                          
				cWRCP	+= " AND (RCP.RCP_MAT " + cMatPerg + ") "
				cWSRE	+= " AND (A.RE_MATD " + cMatPerg + " OR A.RE_MATP " + cMatPerg + ") "
				cWSR8	+= " AND (SR8.R8_MAT " + cMatPerg + ") "
			EndIf   
			If !Empty(cCCustoPerg)                                          
				cWSRE	+= " AND (A.RE_CCD " + StrTran(cCCustoPerg, "RA_CC", "A.RE_CCD") + ") AND (A.RE_CCP " + StrTran(cCCustoPerg, "RA_CC","A.RE_CCP") + ") "
			EndIf	                     
			
	       	If lOpcTransf        
				cSSRE := " UNION ALL "
				cSSRE += "Select "
				cSSRE += "Re_FilialD FilD, Re_FilialP FilP          , Re_EmpD EmpD                , Re_EmpP EmpP, Re_MatD MatD, Re_MatP MatP, "
				cSSRE += "Re_Data DataMov, ' ' Tipo                 , A.Re_CCD CCD                , A.Re_CCP CCP, Re_ProcesD ProcesD, Re_ProcesP ProcesP, "
				cSSRE += "' ' Rcm_Descri, B.CTT_DESC01 CCDDescricao	, C.CTT_DESC01 CCPDescricao   , "
				cSSRE += "0 RCP_SALMES , 0 RCP_SALDII             	, ' ' R8_Pd				  	  , ' ' R8_Tipo , 0 R8_Duracao      , 'SRE' OrSlct "
				cSSRE += "From "+RetSQLName("SRE")+" A "
				cSSRE += "Inner Join "+RetSQLName("CTT")+" B On ("+ iIf( !Empty(cModCSRE), " Re_FilialD=B.Ctt_Filial And ", "") + " A.Re_CCD = B.Ctt_Custo) "
				cSSRE += "Inner Join "+RetSQLName("CTT")+" C On ("+ iIf( !Empty(cModCSRE), " Re_FilialP=C.Ctt_Filial And ", "") + " A.RE_CCP = C.Ctt_Custo) "
				cSSRE += "WHERE A.D_E_L_E_T_=' '  AND B.D_E_L_E_T_=' ' AND C.D_E_L_E_T_=' ' "
				cSSRE += cWSRE
			Else
				cSSRE := ""
			EndIf   
			
			cSSR8 := " UNION ALL "
			cSSR8 += "Select  R8_Filial FilD , ' ' FilP        , ' ' EmpD       , ' ' EmpP      , R8_Mat MatD   , ' ' MatP     , "
			cSSR8 += "R8_DataIni DataMov     , R8_TipoAfa Tipo , ' ' CCD        , ' ' CCP       , ' ' ProcesD   , ' ' ProcesP  ,"
			cSSR8 += "Rcm_Descri , ' ' CCDDescricao, ' ' CCPDescricao,0 RCP_SALMES, 0 RCP_SALDII, "
			cSSR8 += "R8_Pd ,			R8_Tipo                , R8_Duracao      , 'SR8' OrSlct "
			cSSR8 += "From "+RetSqlName("SR8")+" SR8 Inner Join "+RetSqlName("RCM")+" Rcm On Sr8.R8_TipoAfa=Rcm.Rcm_Tipo "
			cSSR8 += "WHERE SR8.D_E_L_E_T_=' ' "
			cSSR8 += cWSR8
			
			If !lOpcAfast .AND. !lOpcFerias
				cSSR8 := ""
			Else
				If !lOpcAfast .OR. !lOpcFerias
					cSSR8 += " AND RCM.RCM_TIPOAF!='4'"
				EndIf
			EndIf 
			                     
			cSSR8 := cSSR8 
			cUnion := "%"+ cWRCP + CSSRE + cSSR8 + "%"
		   
			If Empty(cCamposAdicionais)
				cCamposAdicionais := "%%"
			End if	 
			If Empty(cUnion)
				cUnion := "%%"
			End if
			If Empty(cSitQuery)
				cSitQuery := "%%"
			End if
			If Empty(cCatQuery)
				cCatQuery := "%%"
			End if	  
			If Empty(cDtMov)
				cDtMov := "%%"
			End if		 
					
			cAliasQry := GetNextAlias()
			Do Case	                         
				Case nOrdem == 1 .OR. nOrdem == 3 .OR. nOrdem == 4 .OR. nOrdem == 6
					Begin Report Query oSctCCusto
				Case nOrdem == 2 .OR. nOrdem == 5                 
					Begin Report Query oSctDepartamento
				Case nOrdem == 7           
					Begin Report Query oSctRegPatronal
			End Case
			
			//Prepara variavel de compartilhamento para BeginSql
			cMCSqbSql := "%" + cModCSQB + "%" 
			If Empty(cCCustoP)
				cCCustoP := "%%"
			Else
				cCCustoP := "% AND " + cCCustoP + " %"
			EndIf
			BeginSql Alias cAliasQry
				COLUMN DATAMOV AS DATE
				
				SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_ADMISSA, RA_DEPTO, QB_DESCRIC RA_DDEPTO, RA_SALMES, RA_CC,  
						%exp:CCamposAdicionais%
						FILD, FILP, EMPD, EMPP, MATD, MATP, DATAMOV, TIPO, CCD, CCP, PROCESD, PROCESP, RCM_DESCRI,
						R8_PD, R8_TIPO, R8_DURACAO,
						CCDDESCRICAO, CCPDESCRICAO, RCP_SALMES, RCP_SALDII, ORSLCT
				FROM (
						SELECT 
							RCP_FILIAL FILD    , ' ' FILP        , ' ' EMPD        , ' ' EMPP  , RCP_MAT MATD, ' ' MATP   , 
							RCP_DTMOV DATAMOV  , RCP_TPMOV TIPO  , ' ' CCD         , ' ' CCP  , ' ' PROCESD , ' ' PROCESP,
							' ' RCM_DESCRI     , ' ' CCDDESCRICAO, ' ' CCPDESCRICAO, RCP_SALMES, RCP_SALDII  , 
							' ' R8_PD , ' ' R8_TIPO , 0 R8_DURACAO  , 'RCP' ORSLCT
						FROM %TABLE:RCP% RCP WHERE RCP.%NotDel% %exp:cUnion%
	
					) MVIEW
				INNER JOIN %TABLE:SRA% SRA ON RA_FILIAL=FILD AND RA_MAT=MATD
				INNER JOIN %TABLE:SQB% SQB ON %exp:cMCSqbSql% RA_DEPTO=QB_DEPTO
				%exp:cJoinAdicional%   
				WHERE SRA.%NotDel% AND SQB.%NotDel% %Exp:cCCustoP%
				AND SRA.RA_SITFOLH IN (%exp:cSitQuery%) AND SRA.RA_CATFUNC IN (%EXP:cCatQuery%)
				%exp:cDTMov%
				ORDER BY %exp:cOrderBy%
			EndSql
				
			Do Case          
				Case nOrdem == 1 .OR. nOrdem == 3 .OR. nOrdem == 4 .OR. nOrdem == 6 
					End Report Query oSctCCusto
				Case nOrdem == 2 .OR. nOrdem == 5               
					End Report Query oSctDepartamento 
				Case nOrdem == 7
					End Report Query oSctRegPatronal
			End Case
		 #ENDIF      
	 
	cQryPto   := getLastQuery()[2]
	cQryPto	  := ChangeQuery( cQryPto )
	cAliasPto := GetNextAlias()   
	MsOpenDbf( .T. , "TOPCONN" , TcGenQry( NIL , NIL , cQryPto ) , cAliasPto, .T., .T.)

	//Parent Query
	Do Case
		Case nOrdem == 1 .OR. nOrdem == 2 .OR. nOrdem == 7
			oSctTraj:SetParentQuery()	 
		Case nOrdem == 3
        	oSctDepartamento:SetParentQuery()
        	oSctTraj:SetParentQuery()
  		Case nOrdem == 4 .OR. nOrdem == 5             
        	oSctFuncao:SetParentQuery()
        	oSctTraj:SetParentQuery() 
    	Case nOrdem == 6                     
	       	oSctDepartamento:SetParentQuery()
			oSctFuncao:SetParentQuery()
        	oSctTraj:SetParentQuery()     	
	End Case
	    
	//Parent Filter	    
	Do Case                                                                                             
		Case nOrdem == 1 
			oSctTraj:SetParentFilter( 																	;
							   			{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
							   			{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
      								)    
  		Case nOrdem == 2                 
			oSctTraj:SetParentFilter( 																	;
							   			{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
							   			{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
      								)    
		Case nOrdem == 3                                
            If Empty(cModCCTT)
				oSctDepartamento:SetParentFilter( 																	;
													{|cParam| (cAliasQry)->CTT_CUSTO== cParam},;
													{|| 	   (cAliasQry)->RA_CC}		;
	      										)
	      	Else
				oSctDepartamento:SetParentFilter( 																	;
													{|cParam| (cAliasQry)->CTT_FILIAL+(cAliasQry)->CTT_CUSTO== cParam},;
													{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->RA_CC}		;
	      										)	      	
	      	EndIf   
          
			oSctTraj:SetParentFilter( 																	;
										{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
										{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
    		  						)   
		Case nOrdem == 4   
			If Empty(cModCSRJ)                             
				oSctFuncao:SetParentFilter( 																	;
												{|cParam| (cAliasQry)->RJ_FUNCAO== cParam},;
												{|| 	   (cAliasQry)->RA_CODFUNC}		;
	      									)   
			Else
				oSctFuncao:SetParentFilter( 																	;
												{|cParam| (cAliasQry)->RJ_FILIAL+(cAliasQry)->RJ_FUNCAO== cParam},;
												{|| 	  AllTrim((cAliasQry)->FILD)		+(cAliasQry)->RA_CODFUNC}		;
	      									)   			
			EndIf	          
			oSctTraj:SetParentFilter( 																	;
										{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
										{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
    		  						)  
        Case nOrdem == 5               
			If Empty(cModCSRJ)                             
				oSctFuncao:SetParentFilter( 																	;
												{|cParam| (cAliasQry)->RJ_FUNCAO== cParam},;
												{|| 	   (cAliasQry)->RA_CODFUNC}		;
	      									)   
			Else
				oSctFuncao:SetParentFilter( 																	;
												{|cParam| (cAliasQry)->RJ_FILIAL+(cAliasQry)->RJ_FUNCAO== cParam},;
												{|| 	  AllTrim((cAliasQry)->FILD)		+(cAliasQry)->RA_CODFUNC}		;
	      									)   			
			EndIf
          
			oSctTraj:SetParentFilter( 																	;
										{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
										{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
    		  						) 
   		Case nOrdem == 6 
   			If Empty(cModCSqb)             
				oSctDepartamento:SetParentFilter( 																	;
													{|cParam| (cAliasQry)->QB_DEPTO== cParam},;
													{|| 	  (cAliasQry)->RA_DEPTO}		;
	      										)   
   			Else
				oSctDepartamento:SetParentFilter( 																	;
										{|cParam| (cAliasQry)->QB_FILIAL+(cAliasQry)->QB_DEPTO== cParam},;
										{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->RA_DEPTO}		;
      										)   
    		EndIf
    		If Empty(cModCSRJ)
				oSctFuncao:SetParentFilter( 																	;
												{|cParam| (cAliasQry)->RJ_FUNCAO== cParam},;
												{|| 	  (cAliasQry)->RA_CODFUNC};
	      									)      			
	   		Else
				oSctFuncao:SetParentFilter( 																	;
											{|cParam| (cAliasQry)->RJ_FILIAL+(cAliasQry)->RJ_FUNCAO== cParam},;
											{|| 	  AllTrim((cAliasQry)->FILD	)	+(cAliasQry)->RA_CODFUNC};
      									)      			
   			EndIf
          
			oSctTraj:SetParentFilter( 																	;
										{|cParam| (cAliasQry)->RA_FILIAL +(cAliasQry)->RA_MAT== cParam},;
										{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->MATD}			;
    		  						) 
    	Case nOrdem == 7 
    		If Empty(cModCRCO)
				oSctTraj:SetParentFilter( 																	;
								   			{|cParam| (cAliasQry)->RCO_CODIGO== cParam},;
								   			{|| 	   (cAliasQry)->RA_CODRPAT}			;
	      								)   
	   		Else
				oSctTraj:SetParentFilter( 																	;
								   			{|cParam| (cAliasQry)->RCO_FILIAL +(cAliasQry)->RCO_CODIGO== cParam},;
								   			{|| 	  AllTrim((cAliasQry)->FILD)		 +(cAliasQry)->RA_CODRPAT}			;
      									)   	   		
	   		EndIf
	End Case            
	

/*
  ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณImpressao do Relatorio ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
oReport:SetMeter( (cAliasQry)->(RecCount()) )	//-> Seta a Regua de Impressao 

//Imprime o Relatorio
Do Case 
	Case nOrdem == 1 .OR. nOrdem == 3 .OR. nOrdem == 4 .OR. nOrdem ==6
		oSctCCusto:Print()
	Case nOrdem == 2 .OR. nOrdem == 5
		oSctDepartamento:Print()    
	Case nOrdem == 7                
		oSctRegPatronal:Print()    
End Case
Return Nil                              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER107   บAutor  ณMicrosiga           บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function fImpTrajLaboral(cCondition)
	Local aArea		:= GetArea()              
	Local cSaveCond := ""
	Local cLastFil	:= "!!"
	Local cVerbaFer := ""
	
	cCondition := Replace(cCondition, "cAliasQry", "cAliasPto")
	cSaveCond := &(cCondition) 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime as informacoes Funcionario ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 
	oSctFnc:Init()
	oSctFnc:Cell("RA_FILIAL"	):SetValue( (cAliasQry)->Ra_Filial	)
	oSctFnc:Cell("RA_MAT"		):SetValue( (cAliasQry)->Ra_Mat 	)
	oSctFnc:Cell("RA_NOME"		):SetValue( (cAliasQry)->Ra_Nome 	)
	oSctFnc:Cell("RA_ADMISSA"	):SetValue( (cAliasQry)->Ra_Admissa )
	oSctFnc:Cell("RA_DDEPTO"	):SetValue( (cAliasQry)->Ra_Depto+" - "+(cAliasQry)->Ra_DDepto )
	oSctFnc:Cell("RA_SALMES"	):SetValue( (cAliasQry)->Ra_SalMes 	)
	oSctFnc:PrintLine()
	
	While (cAliasPto)->(!Eof()) .And. (cSaveCond==&(cCondition))	
	
		If (cAliasQry)->OrSlct == "SR8" .And. cLastFil # (cAliasQry)->Ra_Filial
			cVerbaFer	:= FGetCodFol("0072",,If( Empty(cModCSRV), "", (cAliasQry)->Ra_Filial ) )
			cLastFil	:= (cAliasQry)->Ra_Filial
		EndIf
	
		//Inicia a impressao da Traj Laboral	
		Do Case                
			Case (cAliasQry)->OrSlct == "RCP"
				StartSect("RCP")	 
				oSctRCP:Cell("RCP_DTMOV"	):SetValue( (cAliasQry)->DataMov	)	
				oSctRCP:Cell("RCP_TPMOV"	):SetValue( fDescTpMov((cAliasQry)->Tipo))	
				oSctRCP:Cell("RCP_SALMES"	):SetValue( (cAliasQry)->Rcp_SalMes	)	
				oSctRCP:Cell("RCP_SALDII"	):SetValue( (cAliasQry)->Rcp_SalDii	)
			    oSctRCP:PrintLine()          
			    
			Case (cAliasQry)->OrSlct == "SRE"
				StartSect("SRE")
				oSctSRE:Cell("RE_DATA"		):SetValue( (cAliasQry)->DataMov)
				oSctSRE:Cell("RE_EMPD"		):SetValue( (cAliasQry)->EmpD	)
				oSctSRE:Cell("RE_FILIALD"	):SetValue( (cAliasQry)->FilD	)
				oSctSRE:Cell("RE_MATD"		):SetValue( (cAliasQry)->MatD	)
				oSctSRE:Cell("RE_CCD"  		):SetValue( (cAliasQry)->CCD	)
				oSctSRE:Cell("RE_PROCESD"	):SetValue( (cAliasQry)->ProcesD)
				oSctSRE:Cell("RE_EMPP" 		):SetValue( (cAliasQry)->EmpP	)
				oSctSRE:Cell("RE_FILIALP"	):SetValue( (cAliasQry)->FilP	)
				oSctSRE:Cell("RE_MATP"		):SetValue( (cAliasQry)->MatP	)
				oSctSRE:Cell("RE_CCP" 		):SetValue( (cAliasQry)->CCP	)
				oSctSRE:Cell("RE_PROCESP"	):SetValue( (cAliasQry)->ProcesP)		
				oSctSRE:PrintLine() 
				
			Case (cAliasQry)->OrSlct == "SR8"		
				If (;
					 lOpcFerias .And. lOpcAfast .Or. ; //Imprime ferias e afastamentos
					 lOpcFerias .And. !lOpcAfast .And. (cAliasQry)->R8_Pd == cVerbaFer .Or. ; //Imprime soh ferias
					 !lOpcFerias .And. lOpcAfast .And. (cAliasQry)->R8_Pd # cVerbaFer ; //Imprime soh afastamentos
					)

					StartSect("SR8")            
					oSctSR8:Cell("R8_DATAINI"	):SetValue( (cAliasQry)->DataMov	)
					oSctSR8:Cell("R8_TIPOAFA"	):SetValue( AllTrim((cAliasQry)->Tipo)+" - "+(cAliasQry)->RCM_Descric)
					oSctSR8:Cell("R8_DURACAO"	):SetValue( (cAliasQry)->R8_Duracao	)
					oSctSR8:PrintLine()	
				EndIf			
		End Case

		(cAliasPto)->(dbSkip())		                       
		 
		If (cSaveCond==&(cCondition))
			(cAliasQry)->(dbSkip())
		End If

	EndDo 

	oSctFnc:Finish()
	oSctFnc:oReport:SkipLine() 
	oSctFnc:oReport:ThinLine()
	StartSect("")	
	RestArea( aArea )
	
Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER107   บAutor  ณMicrosiga           บ Data ณ  03/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function StartSect(cName)	
	
	If Type("cNameAnt")=="U"
		_SetOwnerPrvt( "cNameAnt", "")	
	EndIf
			
	If Upper(cName)!= Upper(cNameAnt) 
		Do Case
			Case cNameAnt=="RCP"		
				oSctRcp:Finish()
			Case cNameAnt=="SRE"	
				oSctSre:Finish()		
			Case cNameAnt=="SR8"		
				oSctSr8:Finish()
		End Case
		
		Do Case
			Case cName=="RCP"		
				oSctRcp:Init()
			Case cName=="SRE"	
				oSctSre:Init()		
			Case cName=="SR8"		
				oSctSr8:Init()
		End Case
		cNameAnt:= cName
	EndIf 
Return   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER107   บAutor  ณMicrosiga           บ Data ณ  05/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o tipo-Descricao da tabela 30 do SX5,               บฑฑ
ฑฑบ          ณA variavel cTipo pode ser: 1-CarregaArray, 2-BuscaDescricao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fBusDTpSR8(cChave)  
	Local cRDesc	:= ""    

	If TYPE("aArray")=="U"	
		_SetOwnerPrvt( "aArray", {})
    End If
    
    If Len(aArray)==0 
		dbSelectArea("SX5")
		SX5->(DbSeek( xFilial("SX5")+"30"))
		
		While !SX5->(EOF()) .AND. SX5->(X5_TABELA)=="30"
			aAdd(aArray, {SX5->X5_CHAVE, SX5->(X5DESCRI()) } )		
			SX5->(dbSkip())
		EndDo
    endif
    
    nPos:= aScan(aArray, {|x| x[1]=cChave})
    
	If nPos > 0 
		cRDesc :=aArray[nPos][1]+"-"+aArray[nPos][2]
	Else
		cRDesc:=""	
	EndIf	
	
Return (cRDesc) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER107   บAutor  ณMicrosiga           บ Data ณ  03/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fDescTpMov(cTipo)
	Local cDesc 	
	cTipo := AllTrim(cTipo)
	Do Case
		Case cTipo == "01"
			cDesc := "01- "+OemToAnsi(STR0013)		//01=Admissao;
		Case cTipo == "02"
			cDesc := "02- "+OemToAnsi(STR0014)		//02=Baixa IMSS;
		Case cTipo == "03"
			cDesc := "03- "+OemToAnsi(STR0015)		//03=Alta Reg.Patr.;
		Case cTipo == "04"
			cDesc := "04- "+OemToAnsi(STR0016)		//04=Baixa Reg.Patr.;
		Case cTipo == "05"
			cDesc := "05- "+OemToAnsi(STR0017)		//05=Modif.Sal.;
		Case cTipo == "06"
			cDesc := "06- "+OemToAnsi(STR0018)		//06=Reingresso;
		Case cTipo == "07"
			cDesc := "07- "+OemToAnsi(STR0019)		//07=Alta Esp. Infonavit;
		Case cTipo == "20"
			cDesc := "20- "+OemToAnsi(STR0020)		//20=Baixa Folha;
	End Case      

	//01=Admissao;02=Baixa IMSS;03=Alta Reg.Patr.;04=Baixa Reg.Patr.;05=Modif.Sal.;
	//06=Reingresso;07=Alta Esp. Infonavit;20=Baixa Folha
Return cDesc

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER107   บAutor  ณMicrosiga           บ Data ณ  03/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fTpMovGp107()

	Local nSit		:= 0	
	Local cTitulo   := ""
	Local MvParDef  := ""
	Local MvPar     := "" 
	Local MvStrRet	:= ""
	Local l1Elem    := .F. 	
	Local oWnd
	Local cTipoAu
	Private aResul  := {}

	oWnd := GetWndDefault()
	MvPar := &(Alltrim(ReadVar()))     // Carrega Nome da Variavel do Get em Questao
	mvRet := Alltrim(ReadVar())        // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	cTitulo := OemToAnsi(STR0021) //"Opcoes de Trajetoria"
	aResul  := {;
					OemToAnsi(STR0013),; 	//1 - Admissao 
					OemToAnsi(STR0014),; 	//2 - Baixa IMSS 
					OemToAnsi(STR0015),; 	//3 - Alta Reg.Patr.
					OemToAnsi(STR0016),; 	//4 - Baixa Reg.Patr.
					OemToAnsi(STR0017),; 	//5 - Modif.Sal.
					OemToAnsi(STR0018),; 	//6 - Reingresso
					OemToAnsi(STR0019),; 	//7 - Alta Esp. Infonavit
					OemToAnsi(STR0020),; 	//8 - Baixa Folha
					"Afastamentos" ,;		//A - Afastamentos
					"F้rias",;				//B - Ferias
					"Transfer๊ncias";		//C - Transferencias
				}
									
	MvParDef := "12345678ABC"
	
	f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,11)       // Chama funcao f_Opcoes
	
	For nSit := 1 To Len( mvpar )
		If ( SubStr( mvpar, nSit, 1 ) # "*" )
			MvStrRet += SubStr( mvpar , nSit , 1 )
		Endif
	Next nSit	
	
	&MvRet := MvStrRet                           				   	 // Devolve Resultado
	
Return
          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ fQueryVisao   ณ Autor ณ Tania Bronzeri        ณ Data ณ19/03/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Pesquisa Visao / Departamento para a Arquitetura Organizacional.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GPER103                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fQueryVisao() 

	Local aArea		:= GetArea()
	Local aChave	:= array(2)
	Local cQuery 	:= ""
	Local cQryAlias	:= GetNextAlias()
	
	dbSelectArea("RD4")
	dbCloseArea()               
	cQuery := "SELECT RD4.RD4_CHAVE, RD4.RD4_FILIDE FROM " + RetSqlName("RD4") + " RD4 "
	cQuery += "INNER JOIN " + RetSqlName("RDK") + " RDK "
	cQuery += "ON RD4_CODIGO = RDK_CODIGO AND RD4_FILIAL = RDK_FILIAL "
	cQuery += "WHERE RD4_CODIDE = '" + cCodDepto + "' AND RDK_HIERAR = '1' AND RDK_CODIGO = '" + cCodVisao + "' "
	cQuery += "AND RD4.D_E_L_E_T_ <> '*' AND RDK.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryAlias,.T.,.T.)
	
	aChave[1]	:= (cQryAlias)->RD4_FILIDE
	aChave[2]	:= (cQryAlias)->RD4_CHAVE
	
	(cQryAlias)->(DbCloseArea())
	
	RestArea( aArea )	

Return aChave
