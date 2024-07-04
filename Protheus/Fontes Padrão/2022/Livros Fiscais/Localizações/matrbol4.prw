#INCLUDE "rwmake.ch" 
#INCLUDE "MATRBOL4.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ MATRBOL4 ณ Autor ณ Mauricio Canalle      ณ Data ณ 11/03/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ ANEXO 11 - INFORMACION SOBRE LAS VENTAS DE PRODUCTOS       ณฑฑ
ฑฑณ			 ณ	GRABADOS CON TASAS ESPECIFICAS - BOLIVIA				        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Vendas Clientes                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function MATRBOL4(aParam)

If FindFunction("TRepInUse") .And. TRepInUse()
   Processa({|| ReportDef(aParam) })	
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณReportDef ณ Autor ณ Mauricio Canalle      ณ Data ณ 11/03/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณA funcao estatica ReportDef devera ser criada para todos os ณฑฑ
ฑฑณ          ณrelatorios que poderao ser agendados pelo usuario.          ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpO1: Objeto do relat๓rio                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportDef(aParam)

Local oReport 
Local aTotais := {0,0,0,0,0,0,0,0,0,0,0,0,0}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImpressao                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport := TReport():New("MATRBOL4",STR0012,"MATRBOL4R3", {|oReport| PrintBol4(oReport, aTotais) },STR0013 + " " + STR0014)	// "ANEXO 11 - INFORMACION SOBRE LAS VENTAS DE PRODUCTOS GRABADOS CON TASAS ESPECIFICAS"
//Este programa tem como objetivo imprimir relatorio "###"de acordo com os parametros informados pelo usuario."
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)                                  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica as Perguntas Seleciondas                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( aParam == Nil )
	Pergunte(oReport:uParam,.F.)
EndIf

oReport:PrintDialog()

Return                                                                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRBOL4  บAutor  ณMicrosiga           บ Data ณ  03/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PrintBol4( oReport, aTotais )

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(2)
Local cQuery  := ""
Local cLvrIVA := ""
Local cLvrICE := ""
Local cAliasTRB  
Local aColFx1 := {STR0001, STR0002, STR0003, STR0004, STR0005, STR0006, STR0007, STR0008, STR0009}
// "Cantidad"###"Precio de venta"###"Venta total"###"IVA"###"Venda neta total"###"Tasa aplicada"
// "Impuesto Bs"###"Impuesto declarado"###"Diferencia"
Local aColFx2 := { "(1)", "(2)", "(3=1*2)", "(4)", "(5=3-4)", "(6)", "(7=1*6)", "(8)", "(9=7-8)" }
Local cCodAnt := ""
Local nSeqPrd := 1
Local nOrdem  := 1
Local nI      := 0
Local nJ      := 0
Local aRefMes := {}
Local cMesRef := ""
Local aCelula := {{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}       
Local aCol07  := {}
Local aCol08  := {}                     
Local cAliasTMP := "TMP"
Local nPosMes := 0
Private oTmpTable
Private oTmpTRB 

CriaTemp()  // Cria arquivo temporario para armazenar os valores por produto+mes

// Monta vetor com os 12 meses tratados pelo relatorio
// aRefMes[x,1] - ANO+MES
// aRefMes[x,2] - Sequencial                         
// aRefMes[x,1] - descricao do mes
cMesRef := Substr(DtoS(MV_PAR01), 1, 6)   // Ano/Mes Referencia
Aadd(aRefMes, {cMesRef, 1, Tabela("C2", Alltrim(Str(Val(Substr(cMesRef, 5,2)), 2)), .F.)} )

For nI := 2 to 12   
    If Val(Substr(cMesRef, 5,2))+1 > 12
       cMesRef := Strzero(Val(Substr(cMesRef, 1,4))+1, 4)+ '01'
    Else                 
       cMesRef := Substr(cMesRef, 1,4) + Strzero(Val(Substr(cMesRef, 5,2))+1, 2)
    Endif                    
    Aadd(aRefMes, {cMesRef, nI, Tabela("C2", Alltrim(Str(Val(Substr(cMesRef, 5,2)), 2)), .F.)} )
Next

DbSelectArea("SFB")
SFB->(DbSetOrder(1))

// Campo do imposto IVA no SD2
If SFB->(DbSeek(xFilial("SFB")+"IVA"))
   cLvrIVA := SFB->FB_CPOLVRO
Endif

If Empty(cLvrIVA)
   MsgStop(STR0010) //"Verificar cadastro de impostos: IVA. O n๚mero do livro fiscal nใo foi informado"
   Return
Endif

// Campo do imposto ICE no SD2
If SFB->(DbSeek(xFilial("SFB")+"ICE"))
   cLvrICE := SFB->FB_CPOLVRO
Endif

If Empty(cLvrICE)  
   MsgStop(STR0011) // "Verificar cadastro de impostos: ICE. O n๚mero do livro fiscal nใo foi informado"
   Return
Endif

CriaQuery(cLvrICE, cLvrIVA, @cAliasTRB)

DbSelectArea(cAliasTRB)
(cAliasTRB)->(DbGoTop())
      
cCodAnt := (cAliasTRB)->D2_COD    

While !(cAliasTRB)->(Eof())                                          
   nPosMes := aScan(aRefMes, {|x| AllTrim(Upper(x[1])) == (cAliasTRB)->PERIODO})
                     
   If nPosMes > 0 .and. (cAliasTRB)->IMPICE > 0
	   aCelula[1][aRefMes[nPosMes][2]] += If(MV_PAR06==2, ((cAliasTRB)->QTD2-(cAliasTRB)->QTDEV2),;
	                                                        ((cAliasTRB)->QTD1-(cAliasTRB)->QTDEV1))
	   aCelula[2][aRefMes[nPosMes][2]] += ((cAliasTRB)->VLRTOT - (cAliasTRB)->TOTDEV)   
	   aCelula[3][aRefMes[nPosMes][2]] += ((cAliasTRB)->IMPIVA - (cAliasTRB)->IVADEV)   
	Endif   

	(cAliasTRB)->(DbSkip())         
	
	If cCodAnt <> (cAliasTRB)->D2_COD		             
	   nOrdem := 1
	   
	   For nI := 1 to Len(aColFx1)
	   	RecLock("TMP", .T.)    
		   TMP->CODPROD := cCodAnt
	      TMP->SEQPROD := Str(nSeqPrd, 4)
		   TMP->ORDEM   := Strzero(nOrdem, 2)
		   TMP->COLFX1  := aColFx1[nI]
			TMP->COLFX2  := aColFx2[nI]   
			
			If nI == 1 // quantidade         
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := aCelula[1][nJ]
				   TMP->COLUNA13 += aCelula[1][nJ]				   
				Next                               
				nQtdTot := TMP->COLUNA13
			Endif
			     
			If nI == 2 // PRECO UNITARIO
			   For nJ := 1 to 12
			      If aCelula[1][nJ] > 0
				      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
					   &cCampo := ((aCelula[2][nJ]+aCelula[3][nJ])/aCelula[1][nJ])
					   TMP->COLUNA13 += (aCelula[2][nJ]+aCelula[3][nJ])
					Endif					     
				Next   				        
				TMP->COLUNA13 := TMP->COLUNA13/nQtdTot
			Endif		
			
			If nI == 3 // venda total         
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := (aCelula[2][nJ]+aCelula[3][nJ])
				   TMP->COLUNA13 += (aCelula[2][nJ]+aCelula[3][nJ])
				Next   				                          
			Endif

			If nI == 4 // iva
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := aCelula[3][nJ]
				   TMP->COLUNA13 += aCelula[3][nJ]
				Next  
			Endif			
			
			If nI == 5 // venda neta total         
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := aCelula[2][nJ]
				   TMP->COLUNA13 += aCelula[2][nJ]
					aTotais[13]   += aCelula[2][nJ]				   
				   aTotais[nJ]   += aCelula[2][nJ]
				Next   				                          
			Endif                                  
			
			If nI == 6  // taxa ICE
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := Posicione("SFF", 15, xFilial("SFF")+Posicione("SB1", 1, xFilial("SB1")+cCodAnt, "B1_PARTAR"), "FF_ALIQ")
				Next   				                          				
			Endif                
         
			If nI == 7  // taxa aplicada
  			   aCol07 := {}
  			   
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo :=	(aCelula[1][nJ]*;
				   Posicione("SFF", 15, xFilial("SFF")+Posicione("SB1", 1, xFilial("SB1")+cCodAnt, "B1_PARTAR"), "FF_ALIQ"))
				   Aadd(aCol07, (aCelula[1][nJ]*;
				   Posicione("SFF", 15, xFilial("SFF")+Posicione("SB1", 1, xFilial("SB1")+cCodAnt, "B1_PARTAR"), "FF_ALIQ")))            
				   TMP->COLUNA13 += (aCelula[1][nJ]*;
				   Posicione("SFF", 15, xFilial("SFF")+Posicione("SB1", 1, xFilial("SB1")+cCodAnt, "B1_PARTAR"), "FF_ALIQ"))
				Next   				                          				
			Endif               
						
			If nI == 8  // imposto declarado
				aCol08 := {}
				
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
			      AIG->(DbSeek(xFilial("AIG")+'650'+cCodAnt+Substr(aRefMes[nJ][1], 1 , 4))) 
				   &cCampo := &("AIG->AIG_VIMP"+Substr(aRefMes[nJ][1], 5, 2))      
				   Aadd(aCol08, &("AIG->AIG_VIMP"+Substr(aRefMes[nJ][1], 5, 2)))  
				   TMP->COLUNA13 += &("AIG->AIG_VIMP"+Substr(aRefMes[nJ][1], 5, 2))
				Next   				                          				
			Endif
			                                                                                             
			If nI == 9  // diferenca
			   For nJ := 1 to 12
			      cCampo := "TMP->(COLUNA"+(StrZero( nJ,2))+")"
				   &cCampo := (aCol07[nJ] - aCol08[nJ])                             
				   TMP->COLUNA13 += (aCol07[nJ] - aCol08[nJ])
				Next   				                          				
			Endif		
			
			TMP->(MsUnlock())          
			nOrdem++
		Next	
				
		nSeqPrd++
		cCodAnt := (cAliasTRB)->D2_COD
		aCelula := {{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
   Endif
End                    
                  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 1a. secao do relatorio                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
oSection1:= TRSection():New(oReport,"",{"TMP"},/*aOrdem*/)

TRCell():New( oSection1, "CODPROD"	,"TMP", "",/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oSection1, "B1_DESC"	,"SB1", "",/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 2a. secao do relatorio                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
oSection2 := TRSection():New( oSection1, "", {"TMP"}, ) 

TRCell():New(oSection2,"COLFX1"    ,"TMP",	STR0015	, "@!"				   , 23 ,/*lPixel*/,/*{|| code-block de impressao }*/)  // Descricao
TRCell():New(oSection2,"COLFX2"		,"TMP",	STR0016	, "@!"					, 10 ,/*lPixel*/,/*{|| code-block de impressao }*/)  // Calculo
TRCell():New(oSection2,"COLUNA01"	,"TMP",	aRefMes[01,3]+"/"+Substr(aRefMes[01,1],3,2)	, "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA02"	,"TMP",	aRefMes[02,3]+"/"+Substr(aRefMes[02,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New(oSection2,"COLUNA03"	,"TMP",	aRefMes[03,3]+"/"	+Substr(aRefMes[03,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA04"	,"TMP",	aRefMes[04,3]+"/"	+Substr(aRefMes[04,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA05"	,"TMP",	aRefMes[05,3]+"/"	+Substr(aRefMes[05,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA06"	,"TMP",	aRefMes[06,3]+"/"	+Substr(aRefMes[06,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA07"	,"TMP",	aRefMes[07,3]+"/"	+Substr(aRefMes[07,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA08"	,"TMP",	aRefMes[07,3]+"/"	+Substr(aRefMes[08,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA09"	,"TMP",	aRefMes[08,3]+"/"	+Substr(aRefMes[09,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA10"	,"TMP",	aRefMes[10,3]+"/"	+Substr(aRefMes[10,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA11"	,"TMP",	aRefMes[11,3]+"/"	+Substr(aRefMes[11,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA12"	,"TMP",	aRefMes[12,3]+"/"	+Substr(aRefMes[12,1],3,2), "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"COLUNA13"	,"TMP",	"Total"			, "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:Cell("COLUNA01"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA02"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA03"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA04"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA05"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA06"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA07"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA08"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA09"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA10"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA11"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA12"):SetHeaderAlign("RIGHT")
oSection2:Cell("COLUNA13"):SetHeaderAlign("RIGHT")
         

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 3a. secao do relatorio                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

oSection3 := TRSection():New( oSection1, "", {"TMP"}, ) 

TRCell():New(oSection3,"COLFX1" 		,"TMP",	"", "@!"					   , 23, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLFX2" 		,"TMP",	"", "@!" 					, 10, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA01"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA02"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)  
TRCell():New(oSection3,"COLUNA03"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA04"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA05"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA06"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA07"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA08"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA09"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA10"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA11"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA12"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"COLUNA13"	,"TMP",	"", "@e 9,999,999.999"	, 15, /*lPixel*/,/*{|| code-block de impressao }*/)
                                                  
oSection3:Cell("COLUNA01"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA02"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA03"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA04"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA05"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA06"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA07"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA08"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA09"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA10"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA11"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA12"):SetHeaderAlign("RIGHT")
oSection3:Cell("COLUNA13"):SetHeaderAlign("RIGHT")
  
oReport:oPage:nPage := MV_PAR05

oReport:SetMeter(TMP->(LastRec()))       

TMP->(DbGoTop())              
cCodAnt := ""
                                   
While !TMP->(Eof())

	If cCodAnt <> TMP->CODPROD .and. !TMP->(Eof())
		oSection2:Finish()      
	
		// primeira  --> Cabecalho do Produto
		oSection1:Init()                 
		oSection1:Cell("CODPROD" ):SetBlock( { || STR0017+" "+Alltrim(TMP->SEQPROD) } )  // Produto
		oSection1:Cell("B1_DESC"):SetBlock(  { || Posicione("SB1", 1, xFilial("SB1")+TMP->CODPROD, "B1_DESC") } )
		oReport:IncMeter()
		oSection1:PrintLine()
		oSection1:Finish()      
		
		cCodAnt := TMP->CODPROD

		// segunda  --> valores por mes
		oSection2:Init()                 
		oSection2:Cell("COLFX1" ):SetBlock(  { || TMP->COLFX1 } )
		oSection2:Cell("COLFX2"):SetBlock(   { || TMP->COLFX2 } )
		oSection2:Cell("COLUNA01"):SetBlock( { || TMP->COLUNA01 } )	
		oSection2:Cell("COLUNA02"):SetBlock( { || TMP->COLUNA02 } )	
		oSection2:Cell("COLUNA03"):SetBlock( { || TMP->COLUNA03 } )	
		oSection2:Cell("COLUNA04"):SetBlock( { || TMP->COLUNA04 } )	
		oSection2:Cell("COLUNA05"):SetBlock( { || TMP->COLUNA05 } )	
		oSection2:Cell("COLUNA06"):SetBlock( { || TMP->COLUNA06 } )	
		oSection2:Cell("COLUNA07"):SetBlock( { || TMP->COLUNA07 } )	
		oSection2:Cell("COLUNA08"):SetBlock( { || TMP->COLUNA08 } )	
		oSection2:Cell("COLUNA09"):SetBlock( { || TMP->COLUNA09 } )	
		oSection2:Cell("COLUNA10"):SetBlock( { || TMP->COLUNA10 } )	
		oSection2:Cell("COLUNA11"):SetBlock( { || TMP->COLUNA11 } )	
		oSection2:Cell("COLUNA12"):SetBlock( { || TMP->COLUNA12 } )	
		oSection2:Cell("COLUNA13"):SetBlock( { || TMP->COLUNA13 } )								
	Endif	

	oReport:IncMeter()
	oSection2:PrintLine()
	
	TMP->(DbSkip())
End	

oSection2:Finish()      

// Terceira  --> Totais
oSection3:Init()                 
oSection3:Cell("COLFX1"):SetBlock( { || STR0018 } )  //Total vendas Liquidas
oSection3:Cell("COLFX2"):SetBlock( { || "(Sum 5)" } )
oSection3:Cell("COLUNA01"):SetBlock( { || aTotais[1] } )	
oSection3:Cell("COLUNA02"):SetBlock( { || aTotais[2] } )	
oSection3:Cell("COLUNA03"):SetBlock( { || aTotais[3] } )	
oSection3:Cell("COLUNA04"):SetBlock( { || aTotais[4] } )	
oSection3:Cell("COLUNA05"):SetBlock( { || aTotais[5] } )	
oSection3:Cell("COLUNA06"):SetBlock( { || aTotais[6] } )	
oSection3:Cell("COLUNA07"):SetBlock( { || aTotais[7] } )	
oSection3:Cell("COLUNA08"):SetBlock( { || aTotais[8] } )	
oSection3:Cell("COLUNA09"):SetBlock( { || aTotais[9] } )	
oSection3:Cell("COLUNA10"):SetBlock( { || aTotais[10] } )	
oSection3:Cell("COLUNA11"):SetBlock( { || aTotais[11] } )	
oSection3:Cell("COLUNA12"):SetBlock( { || aTotais[12] } )	
oSection3:Cell("COLUNA13"):SetBlock( { || aTotais[13] } )								

oReport:IncMeter()
oSection3:PrintLine()   
oSection3:Finish() 

DbSelectArea("TMP")      
TMP->(DbCloseArea())

DbSelectArea(cAliasTRB)      
(cAliasTRB)->(DbCloseArea())     

Return                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRBOL4  บAutor  ณMicrosiga           บ Data ณ  03/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaTemp
Local cArqTmp := ""
Local cIndTmp := ""   
Local cTemp := "TMP"
Local aIndex := {'CODPROD','ORDEM'}
Local aCampos := 	{	;
						{	"CODPROD"	,"C", 15, 00	},;  
						{	"SEQPROD"	,"C", 04, 00	},;      
						{	"ORDEM"		,"C", 02, 00	},;      
						{	"COLFX1"		,"C", 25, 00	},;
						{	"COLFX2" 	,"C", 10, 00	},;
						{	"COLUNA01"	,"N", 15, 03	},;
						{	"COLUNA02"	,"N", 15, 03	},;
						{	"COLUNA03"	,"N", 15, 03	},;
						{	"COLUNA04"	,"N", 15, 03	},;
						{	"COLUNA05"	,"N", 15, 03	},;
						{	"COLUNA06"	,"N", 15, 03	},;
						{	"COLUNA07"	,"N", 15, 03	},;
						{	"COLUNA08"	,"N", 15, 03	},;
						{	"COLUNA09"	,"N", 15, 03	},;
						{	"COLUNA10"	,"N", 15, 03	},;
						{	"COLUNA11"	,"N", 15, 03	},;
						{	"COLUNA12"	,"N", 15, 03	},;
						{	"COLUNA13"	,"N", 15, 03	}}
						
	oTmpTable:= FWTemporaryTable():New(cTemp) 
	oTmpTable:SetFields( aCampos ) 
	oTmpTable:AddIndex("1",aIndex)
	//Creacion de la tabla
	oTmpTable:Create()

Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATRBOL4  บAutor  ณMicrosiga           บ Data ณ  03/20/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaQuery(cLvrICE, cLvrIVA, cAliasTRB)

cAliasTRB := GetNextAlias()                    
                                                 
If !(AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
   cQuery := "SELECT D2_COD, SUBSTRING(D2_EMISSAO,1,6) PERIODO, SUM(D2_QUANT) QTD1, SUM(D2_QTSEGUM) QTD2, SUM(D2_TOTAL) VLRTOT, "
Else
   cQuery := "SELECT D2_COD, SUBSTR(D2_EMISSAO,1,6) PERIODO, SUM(D2_QUANT) QTD1, SUM(D2_QTSEGUM) QTD2, SUM(D2_TOTAL) VLRTOT, "
Endif     

cQuery += "SUM(D2_VALIMP"+cLvrIVA+") IMPIVA, SUM(D2_VALIMP"+cLvrICE+") IMPICE, "                             
cQuery += "SUM(D1_QUANT) QTDEV1, SUM(D1_QTSEGUM) QTDEV2, SUM(D1_TOTAL) TOTDEV, "                             
cQuery += "SUM(D1_VALIMP"+cLvrIVA+") IVADEV "                             

cQuery += "FROM "
cQuery += RetSqlName("SF2") + " SF2, "   
cQuery += RetSqlName("SFC") + " SFC, "   
cQuery += RetSqlName("SD2") + " SD2  "   

cQuery += "LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL = SD2.D2_FILIAL AND SD1.D_E_L_E_T_ = ' ' AND "
cQuery += "SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND "
cQuery += "SD1.D1_ESPECIE IN ('NCC', 'NDE') "

cQuery += "WHERE "

cQuery += "SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
cQuery += "SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
cQuery += "SFC.FC_FILIAL = '" + xFilial("SFC") + "' AND "

cQuery += "SD2.D_E_L_E_T_ = ' ' AND "
cQuery += "SF2.D_E_L_E_T_ = ' ' AND "
cQuery += "SFC.D_E_L_E_T_ = ' ' AND "

cQuery += "SD2.D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' AND "
cQuery += "SD2.D2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cQuery += "SD2.D2_TES = SFC.FC_TES AND "                                             
cQuery += "SFC.FC_IMPOSTO = 'ICE'  AND "
cQuery += "SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND "
cQuery += "SF2.F2_TIPO = 'N' "
                                                       
If !(AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
  cQuery += "GROUP BY D2_COD, SUBSTRING(D2_EMISSAO,1,6) "
  cQuery += "ORDER BY D2_COD, SUBSTRING(D2_EMISSAO,1,6) "                          
Else
  cQuery += "GROUP BY D2_COD, SUBSTR(D2_EMISSAO,1,6) "
  cQuery += "ORDER BY D2_COD, SUBSTR(D2_EMISSAO,1,6) "
Endif  

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTRB, .T., .T. )
                          
Return