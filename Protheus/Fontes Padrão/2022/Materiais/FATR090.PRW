#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATR090.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATR090   บAutor  ณEduardo Gomes Juniorบ Data ณ  14/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de horas orcadas x projeto oficial				    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATR090()

Local aArea			:= GetArea()
Local aEscopoPrj	:= {}
Local nLeE			:= 1
Local aPrepHeade	:= {}
Local aPrepAcols	:= {}
Local cQtdCalc
Local aExcel		:= {}
Local aModOrigens	:= {}
Local nPosOri		:= 0
Local lContinua	:= .F.

Private wnrel		:= 'FATR090'
Private cTitulo		:= STR0001	//"Or็ado X Ajustado"
Private cTamanho  	:= "G" // P = 80, M = 136, G = 220
Private cNomeProg	:= 'CRPMSR20'
Private Cabec1		:= STR0002	//"                                                                                                     Horas Proposta      Horas Originais    "
Private Cabec2		:= ""       
Private Cabec3		:= ""
Private aReturn		:= { STR0003, 1, STR0004, 2, 1, 1, "", 1 }	//"Zebrado"###"Administracao"

Private cNrOrcame
Private cSimulacao
Private cVersao
Private nTipRel
Private nHorasSN

If	!IsInCallStack("A600SERVICOS")
	
	If	Pergunte( "FATR90A" , .T. )

		lContinua := .T.
	
		cNrOrcame 		:= MV_PAR01
		cSimulacao 	:= MV_PAR02
		cVersao		:= MV_PAR03
		nTipRel		:= MV_PAR04
		nHorasSN		:= MV_PAR05
	Endif 
	
Else
	
	If	Pergunte( "FATR90B" , .T. )
		lContinua := .T.

		cNrOrcame 		:= M->AF1_CODORC
		cSimulacao 	:= M->AF1_ORCAME
		cVersao		:= M->AF1_VERSAO
		nTipRel		:= MV_PAR01
		nHorasSN		:= MV_PAR02
			
	Endif 
	 
Endif 


If	lContinua

	dbSelectArea("ADZ")
	dbSetOrder(1)
	If	!dbSeek(xFilial("ADZ")+cNrOrcame)
	    MsgAlert(STR0006,STR0005)	//"Proposta informada nใo encontrada!"###"Aten็ใo"
    Else
    
    	If	!Empty(cSimulacao) 
    	
		    MsgRun(STR0007,cTitulo,{|| aModOrigens := R090PqSmOri(cSimulacao,cVersao) })	//Esta funcao preenche o array com o escopo da simulacao original		//"Aguarde analisando projeto original..."
		    MsgRun(STR0008,cTitulo,{||aEscopoPrj := Ft530Ordem(cSimulacao,cVersao) })		//Esta funcao preenche o array com o escopo da simulacao realizando ordenacao dos itesn	//"Aguarde analisando projeto informado..."
    
    		IF	nTipRel == 1
    	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Relatorio ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤู
				If	Len(aEscopoPrj) > 1
					R090ImpEscPrj(cTamanho, cTitulo,aEscopoPrj,cNrOrcame,cSimulacao,cVersao,aModOrigens)
				Else
				    MsgAlert(STR0009,STR0005)	//"Nao existes itens no projeto","Aten็ใo"
				Endif 		
				
	    	Else
    	
				//ฺฤฤฤฤฤฤฤฟ
				//ณ Excel ณ
				//ภฤฤฤฤฤฤฤู
				aPrepHeade := {STR0010,STR0011,STR0012,STR0013}	//"EDT/TAREFA","Descricao","Horas Proposta","Horas Originais"
				
				For nLeE=1 To Len(aEscopoPrj)
				
					If	aEscopoPrj[nLeE,6] <> "001"
				
						cQtdCalc := R090CalcQtd( aEscopoPrj[nLeE,4], aEscopoPrj[nLeE,10], aEscopoPrj )
						
						If	EMPTY(aEscopoPrj[nLeE,12])
							nColPos := 13
						Else
							nColPos := 12	
						Endif

						nPosOri := Ascan(aModOrigens,{|x| Alltrim(x[2])+Alltrim(x[3]) == Alltrim(aEscopoPrj[nLeE,nColPos])+alltrim(aEscopoPrj[nLeE,7]) })
						
						If	nPosOri>0
							cQtdOrig := aModOrigens[nPosOri,4]
						Else 		
							cQtdOrig := "0" 
						Endif 	
				
						Aadd(aPrepAcols,{aEscopoPrj[nLeE,4],aEscopoPrj[nLeE,7],R090CalcQtd:=StrTran(cQtdCalc,".",","),cQtdOrig:=StrTran(cQtdOrig,".",",") })
						
					Endif 
										
				Next 
				
				AAdD(aExcel , {"ARRAY",STR0014+cNrOrcame+STR0015+cSimulacao+STR0016+cVersao, aPrepHeade, aPrepAcols} )	//"Proposta Comercial: "###" Simula็ใo: "###" - Versใo: "

				If 	Len(aExcel) > 0

					DlgToExcel(aExcel)
	
					While ApMsgNoYes(STR0017)	//"Deseja exportar novamente para excel?"
						DlgToExcel(aExcel)
					EndDo
				Else
					ApMsgStop(STR0018)	//"Nใo hแ dados!"
				EndIf
		
	    	Endif
	    	
		Else
		
			MsgAlert(STR0019,STR0005) 	//"Proposta informado nใo possui projeto criado"###"Aten็ใo"
    
        Endif 
        
	Endif 

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR090ImpEscPrjบAutor  ณEduardo Gomes Juniorบ Data ณ  14/04/15   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de horas orcadas x projeto oficial				       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R090ImpEscPrj( cTamanho, cTitulo, aEscopoPrj, cProposta, cNumPMS, cPMSVersao, aModOrigens )

Local cDesc1  := STR0020	///"Este relat๓rio imprime Or็ado X Ajustado conforme estrutura da EDT."
Local cDesc2  := ""
Local cDesc3  := ""

wnrel := SetPrint( "AF1", wnrel,, @cTitulo, cDesc1, cDesc2, cDesc3, .F., , .T., cTamanho )

If nLastKey == 27
   Return( Nil )
Endif

SetDefault( aReturn, "AF1" )

nTipo := Iif( aReturn[4] == 1, 15, 18 )

If nLastKey == 27
   Return( Nil )
EndIf

RptStatus( { || R090IniImpres( wnrel, cTamanho, @cTitulo, aEscopoPrj, cProposta, cNumPMS, cPMSVersao, aModOrigens ) } , STR0021, STR0022 , .T. )	//"Aguarde..."###"Processando registros..."

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR090IniImpresบAutor  ณEduardo Gomes Juniorบ Data ณ  14/04/15   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de horas orcadas x projeto oficial				       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R090IniImpres( wnrel, cTamanho, cTitulo, aEscopoPrj, cProposta, cNumPMS, cPMSVersao,  aModOrigens )

Local nTotReg		:= 0
Local nTotGReg		:= 0
Local nLePrj		:= 1
Local cQtdCalc
Local cQtdOrig

Private Li			:= 80
Private cNomeProg	:= 'CRPMSR20'                              

Private M_PAG		:= 1

For nLePrj:=1 To Len(aEscopoPrj)

	If Li > 55
		Cabec( cTitulo, STR0014+cProposta+STR0015+cNumPMS+STR0016+cPMSVersao  , "", cNomeProg, cTamanho, nTipo )	//"Proposta Comercial: "###" Simula็ใo: "###" - Versใo: "
		Li ++
		@ Li, 001 PSay Cabec1
		Li ++
	Endif
	
	If	EMPTY(aEscopoPrj[nLePrj,12])
		nColPos := 13
	Else
		nColPos := 12	
	Endif
			
	nPosOri := Ascan(aModOrigens,{|x| Alltrim(x[2])+Alltrim(x[3]) == Alltrim(aEscopoPrj[nLePrj,nColPos])+alltrim(aEscopoPrj[nLePrj,7]) })
	
	If	nPosOri>0
		cQtdOrig := aModOrigens[nPosOri,4]
	Else 		
		cQtdOrig := "0" 
	Endif 
	
	cQtdCalc := R090CalcQtd( aEscopoPrj[nLePrj,4], aEscopoPrj[nLePrj,10], aEscopoPrj )	
	
	If	aEscopoPrj[nLePrj,6] <> "001"
		@ Li, If( Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) > 0, Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) + 5, 01 ) PSay aEscopoPrj[nLePrj,7] + Space(15 - If( Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) > 0, Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) + 5, 01 )) + If( Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) > 0, cQtdCalc + ' horas' , '' ) + "        " +If( Len( AllTrim( aEscopoPrj[nLePrj,4] ) ) > 0, cQtdOrig + ' horas' , '' )
		Li ++
	Endif 		

Next nLePrj

@ Li, 000 PSay __PrtThinLine()
Li ++

If Li <> 80
   Roda(,,cTamanho)
Endif

If aReturn[5] == 1
   Set Printer TO
   dbCommitAll()
   Ourspool( wnrel )
EndIf

Ms_Flush()

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR090PqSmOriบAutor  ณEduardo Gomes Juniorบ Data ณ  13/09/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de horas orcadas x projeto oficial				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R090PqSmOri(cSimulacao,cVersao)

Local cQuery
Local aModO_PO	:= {}

Local aModOrigem	:= {}
Local nLeE	:= 1

cQuery := " SELECT AF5_MODORI , ( SELECT SUM (AF5_QUANT) FROM "+RetSqlName("AF5") + " " + "AF5O"+" WHERE AF5O.AF5_EDTPAI=AF5A.AF5_MODORI ) AS NTOTORI "
cQuery += " FROM "+RetSqlName("AF5") + " " + "AF5A"+" WHERE AF5A.AF5_ORCAME = '"+cSimulacao+"' AND AF5A.AF5_VERSAO = '"+cVersao+"' AND AF5A.AF5_MODORI<> '' AND AF5A.D_E_L_E_T_=' '"

cQuery := ChangeQuery( cQuery )
	
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "MOD_ORI",.T.,.T.)

dbSelectArea("MOD_ORI")
dbGotop()

While !EOF()

	aModO_PO := Ft530Ordem(MOD_ORI->AF5_MODORI)
	
	For nLeE=1 To Len(aModO_PO)
	
		If	Alltrim(aModO_PO[nLeE,4]) == Alltrim(MOD_ORI->AF5_MODORI)
			cQtdCalc := cValToChar( MOD_ORI->NTOTORI )	
		Else
			cQtdCalc := R090CalcQtd( aModO_PO[nLeE,4], aModO_PO[nLeE,10], aModO_PO )		
		Endif 

		Aadd(aModOrigem,{aModO_PO[nLeE,1],aModO_PO[nLeE,4],aModO_PO[nLeE,7],cQtdCalc:=StrTran(cQtdCalc,".",",") })
										
	Next 	
	
	dbSelectArea("MOD_ORI")
	dbSkip()

Enddo

MOD_ORI->( dbCloseArea())

Return(aModOrigem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR090CalcQtd บAutor  ณEduardo Gomes Juniorบ Data ณ  14/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de pre-escopo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function R090CalcQtd(cEDTPos, nQtdPos, aEscopoPrj)

Local aArea 	:= GetArea()
Local nLe		:= 1
Local nLeProx	:= 1
Local nQuant	:= nQtdPos

If	Len( AllTrim(cEDTPos) ) = 2

	nQuant	:= 0	
	nLeProx += 1	

	For nLe:=nLeProx To Len(aEscopoPrj)

		If	Len( AllTrim(aEscopoPrj[nLe,4] ) ) > 2 

			If 	Len(AllTrim( aEscopoPrj[nLe,4] ) ) = 5 .AND. AllTrim( aEscopoPrj[nLe,5] ) == Alltrim( cEDTPos )
				nQuant += aEscopoPrj[nLe,10]
			Endif
			
		Endif 			
	
	Next nLe

EndIf

RestArea(aArea)

Return cValToChar( nQuant )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR090VldPropบAutor  ณEduardo Gomes Juniorบ Data ณ  14/04/15   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida proposta informada nos parametros do relatorio	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRMA290 - WORKAREA / FATA530 - SIMULADOR DE HORAS           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function R090VldProp()


If	!IsInCallStack("A600SERVICOS")
	
		cNrOrcame 		:= MV_PAR01
	
Else
	
		cNrOrcame 		:= M->AF1_CODORC
	 
Endif 

dbSelectArea("ADZ")
dbSetOrder(1)
If	!dbSeek(xFilial("ADZ")+cNrOrcame)
    MsgAlert(STR0005,STR0004)	//"Proposta informada nใo encontrada!"###"Aten็ใo"
Else
	If	EMPTY(ADZ->ADZ_PMS)
		MsgAlert(STR0020,STR0004)	//"Proposta comercial informada nใo possui servi็o (simulador de horas) vinculada!"###"Aten็ใo"
	Else 
		cSimulacao	 := ADZ->ADZ_PMS
		cVersao	 := ADZ->ADZ_PMSVER
	Endif 
Endif
