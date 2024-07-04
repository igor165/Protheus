#INCLUDE "HSPAHRC3.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRC3  บ Autor ณ MARCELO JOSE       บ Data ณ  22/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXTRATO DE PRONTUARIOS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRC3()
 Local cDesc1         	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         	:= STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         	:= STR0003 //"Extrato de Prontuarios"
 Local cPict          	:= ""
 Local titulo         	:= STR0003 //"EXTRATO DE PRONTUARIOS"
 Local nLin           	:= 80

 Local Cabec1         	:= ""
 Local Cabec2         	:= ""
 Local imprime        	:= .T.
 Local aOrd           	:= {}

 Private lEnd         	:= .F.
 Private lAbortPrint  	:= .F.
 Private limite       	:= 220
 Private tamanho      	:= "G"
 Private nomeprog     	:= "HSPAHRC3" 
 Private nTipo        	:= 18
 Private aReturn      	:= {STR0004 , 1,STR0005, 2, 1, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     	:= 0
 Private cbtxt        	:= Space(10)
 Private cbcont       	:= 00
 Private CONTFL       	:= 01
 Private m_pag        	:= 01
 Private wnrel        	:= "HSPAHRC3"
 Private cString      	:= "GSA"
 Private cPerg        	:= "HSPRC3"
 Private aSolicita    	:= {}
 Private cCODIMP 						:= ""
 Private nMaxLin 						:= 0 // quantidade maxima de linhas p/ impressao
 
 Private dDtSolIni 				:= CriaVar("GSA_DATSOL", .F.), dDtSolFim := CriaVar("GSA_DATSOL", .F.) 
 Private cCodCrmIni				:= "", cCodCrmFim	:= ""
 
 Private cGsaRegGer				:= ""

	nMaxLin := HS_MaxLin(cCODIMP)


 If FunName() == "HSPAHA95"
  	
 	If !Pergunte(cPerg,.T.)
   return(Nil)
	 EndIf

  M->GSA_REGGER := GSB->GSB_REGGER
  M->GSA_NOMEND := GSB->GSB_DESEND
  M->GSA_NOMPAC := HS_INIPADR("GBH", 1, GSB->GSB_REGGER, "GBH_NOME",,.F.)
  M->GSA_CODEND := GSB->GSB_CODEND

 	dDtSolIni 	:= MV_PAR01
 	dDtSolFim 	:= MV_PAR02
 	cCodCrmIni	:= MV_PAR03
 	cCodCrmFim	:= MV_PAR04
 Else 
  
 	
 	If !Pergunte("HSRC3A",.T.)
   return(Nil)
	 EndIf
   
  M->GSA_REGGER := MV_PAR01
  M->GSA_CODEND := MV_PAR02
  M->GSA_NOMEND := HS_IniPadR("GSD", 1, M->GSA_CODEND, "GSD_DESEND",, .F.)
  M->GSA_NOMPAC := HS_INIPADR("GBH", 1, M->GSA_REGGER, "GBH_NOME",,.F.)

 	dDtSolIni 	:= MV_PAR03
 	dDtSolFim 	:= MV_PAR04
 	cCodCrmIni	:= MV_PAR05
 	cCodCrmFim	:= MV_PAR06
   
 EndIf 


 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F.)

 Processa({|| FS_MontaM()})

 If nLastKey == ESC
  Return(Nil)
 Endif

 nTipo 		:= If(aReturn[4] == 1, 15, 18)

 SetDefault(aReturn, cString)

 If nLastKey == ESC
  Return(Nil)
 Endif


 If LEN(aSolicita) == 0 
  HS_MsgInf(STR0024, STR0027, STR0028) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Extratos de Prontuarios"
  MS_FLUSH()
  Return(NIL)
 EndIf
 
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
  
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณFS_MontaM()บ Autor ณ MARCELO JOSE      บ Data ณ  22/11/04   บฑฑ 
ฑฑบAlteracao ณ           บ       ณ Antonio Carlos    บ Data ณ  14/06/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta matriz para impressao                                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MontaM()
 Local bWhile, cAliasQRY
          
	 If TCSrvType() <> "AS/400"
  	bWhile := {||!Eof()}                             
 	 cAliasQRY := "RC3QRY"
 	 cQuery := "SELECT GSA.R_E_C_N_O_ GSA_RECNO, "
 	 cQuery += "GSA.GSA_OK GSA_OK, "
 	 cQuery += "GSA.GSA_CODSOL GSA_CODSOL, "
 	 cQuery += "GSA.GSA_DATSOL GSA_DATSOL, "
 	 cQuery += "GSA.GSA_HORSOL GSA_HORSOL, "
 	 cQuery += "GSA.GSA_NOMSOL GSA_NOMSOL, "
   cQuery += "GSA.GSA_DATRET GSA_DATRET, "
   cQuery += "GSA.GSA_HORRET GSA_HORRET, "   
   cQuery += "GSA.GSA_CODEND GSA_CODEND, "
 	 cQuery += "GSA.GSA_NOMENT GSA_NOMENT, "
 	 cQuery += "GSA.GSA_NOMRET GSA_NOMRET, "
 	 cQuery += "GSA.GSA_CODPRO GSA_CODPRO, "
 	 cQuery += "GSA.GSA_OBSERV GSA_OBSERV, "
 	 cQuery += "GSA.GSA_DATENT GSA_DATENT, "
 	 cQuery += "GSA.GSA_HORENT GSA_HORENT, "
 	 cQuery += "GSA.GSA_CODMOT GSA_CODMOT, "
 	 cQuery += "GSA.GSA_LOTE GSA_LOTE, "
 	 cQuery += "GCS.GCS_NOMLOC GCS_NOMLOC, "
	  cQuery += "SRA.RA_NOME RA_NOME "
 	 cQuery += "FROM "+RetSqlName("GSA") + " GSA " 
 	 cQuery += "     JOIN "+RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GSA_CODLOC AND GCS.GCS_FILIAL = '" + xFilial( "GCS" ) + "' AND GCS.D_E_L_E_T_ <> '*' " 
 	 cQuery += "LEFT JOIN "+RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO = GSA_CODCRM AND SRA.RA_FILIAL = '" + xFilial( "SRA" ) + "' AND SRA.D_E_L_E_T_ <> '*' " 
 	 cQuery += "WHERE "
 	 cQuery += "GSA.GSA_FILIAL = '" + xFilial( "GSA" ) + "' AND GSA.D_E_L_E_T_ <> '*' " 
   cQuery += " AND GSA.GSA_REGGER = '" + M->GSA_REGGER + "' "
   cQuery += " AND GSA.GSA_CODEND = '" + M->GSA_CODEND + "' "
   cQuery += " AND GSA.GSA_CODCRM BETWEEN '" + cCodCrmIni + "' AND '" + cCodCrmFim + "' "
   cQuery += " AND GSA.GSA_DATSOL BETWEEN '" + DTOS(dDtSolIni) + "' AND '" + DTOS(dDtSolFim) + "'"
     
   cQuery += " ORDER BY GSA_CODSOL"

	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

   DbSelectArea(cAliasQRY)

	 	While (cAliasQRY)->(Eval(bWhile))
    /*
    Posicoes do aSolicita:
    -----------------------------------
    01 - OK
    02 - Codigo da solicitacao
    03 - Data da solicitacao
    04 - Hora da solicitacao
    05 - Nome usuario solicitacao
    06 - Descricao do setor
    07 - Nome do medico
    08 - Data do retorno do pront.
    09 - Hora do retorno do pront.
    10 - Descricao do motivo
    11 - Codigo do endereco
    12 - Usuario que entregou
    13 - Usuario que retorno
    14 - Cod. produto/procedimento
    15 - Descricao produto/procedimento
    16 - Observao da solicitacao           
    17 - Data de entrega do pront.
    18 - Hora de entrega do pront.
    19 - RecNo            
    20 - Lote (Protocolo)
    -----------------------------------
    */
    aAdd(aSolicita,{	(cAliasQRY)->GSA_OK,;
                     (cAliasQRY)->GSA_CODSOL,;
                     STOD((cAliasQRY)->GSA_DATSOL),;
                     (cAliasQRY)->GSA_HORSOL,;
                     PADR((cAliasQRY)->GSA_NOMSOL,30),;
                     PADR((cAliasQRY)->GCS_NOMLOC,25) ,;
                     PADR((cAliasQRY)->RA_NOME,25) ,;
                     STOD((cAliasQRY)->GSA_DATRET),;
                     (cAliasQRY)->GSA_HORRET,;
                     HS_IniPadr("GSC", 1, (cAliasQRY)->GSA_CODMOT, "GSC_DESMOT",, .F.),;
                     (cAliasQRY)->GSA_CODEND,;
                     SUBSTR((cAliasQRY)->GSA_NOMENT, 1, 13),;
                     SUBSTR((cAliasQRY)->GSA_NOMRET, 1, 13),;
                     (cAliasQRY)->GSA_CODPRO,;
                     (cAliasQRY)->(HS_IniPadr("GA7", 1, (cAliasQRY)->GSA_CODPRO, "GA7_DESC",, .F.)),;
                     (cAliasQRY)->GSA_OBSERV,;
                     STOD((cAliasQRY)->GSA_DATENT),;
                     (cAliasQRY)->GSA_HORENT,;
                     (cAliasQRY)->GSA_RECNO,;
                     (cAliasQRY)->GSA_LOTE })
                        
    DbSkip()
   EndDo
   DbSelectArea(cAliasQRY)
 	 dbCloseArea()
  EndIf

Return(Nil)



/******************************************************************************************************************/
/*Funcao    RUNREPORT  Autor : AP6 IDE               Data   22/11/04                                              */
/*Descricao Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.*/
/*Uso       Programa principal                                                                                    */ 
/******************************************************************************************************************/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
 
 Local nCtaFor 			:= 1, nLinMemo := 0, nMemoFor := 0, nTotMov := 0
 Local lImpCabec 	:= .F.
 
 If lAbortPrint
  @ nLin, 00 Psay STR0007 //"INTERROMPIDO PELO USUARIO...."
  Return(Nil)
 EndIf    

 If Len(aSolicita) > 0  

  For nCtaFor := 1 to Len(aSolicita)
   
   
   If (nLin > nMaxLin)
   	nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	   nLin++
		  If !lImpCabec
		  	@ nLin++,00 Psay STR0008 + M->GSA_NOMPAC //"Nome..........: "
		  	@ nLin++,00 Psay STR0009 + M->GSA_REGGER //"Prontuario No.: "
		  	@ nLin++,00 Psay STR0011 + M->GSA_NOMEND //"Descricao ....: "
		  	@ nLin++,00 Psay 	Replicate("_", limite)
		  	           				//            1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
		  																//	"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
		  	@ nLin++,00 Psay		STR0012 //"Solic. Data     Hora  Solicitante     Setor                     Medico                    Procedimento                                       Motivo                    Protoc Endereco     Saida      Hora  Usuario Entrega"
		  	@ nLin++,00 Psay		STR0029 //"                      Obs Solicita็ใo                                                     Obs Encerramento                                                                                 Retorno    Hora  Usuario Retorno"
		  	@ nLin++,00 Psay 	STR0013 //"______ ________ _____ _______________ _________________________ _________________________ __________________________________________________ _________________________ ______ ____________ ________   _____ ________________"
		  	lImpCabec := .T.
		  EndIf
   EndIf

   @ nLin, 000 Psay aSolicita[nCtaFor, 02]  																																																//	Solicitacao
   @ nLin, 007 Psay HS_DTOC(aSolicita[nCtaFor, 03], 1)    																																		//	Data
   @ nLin, 016 Psay aSolicita[nCtaFor, 04]																																																		//	Hora
   @ nLin, 022 Psay SubStr(aSolicita[nCtaFor, 05], 1, 15)																																		// Solicitante
   @ nLin, 038 Psay SubStr(aSolicita[nCtaFor, 06], 1, 25)																																		// Setor
   @ nLin, 064 Psay SubStr(aSolicita[nCtaFor, 07], 1, 25)																																		// Medico
   @ nLin, 090 Psay aSolicita[nCtaFor, 14	] + " " + SubStr(aSolicita[nCtaFor, 15	],	1, 40)		//	Procedimento
   @ nLin, 141 Psay SubStr(aSolicita[nCtaFor, 10	],	1, 25) 																																	// Motivo
   @ nLin, 167 Psay aSOlicita[nCtaFor, 20	]                    																														// Protocolo
   @ nLin, 174 Psay aSOlicita[nCtaFor, 11	]																																																		// Endereco
   @ nLin, 187 Psay IIF(Empty(aSOlicita[nCtaFor][17]), Space(TamSx3("GSA_DATENT")[1]), HS_DTOC(aSOlicita[nCtaFor][17], 1))	// Saida (Entrega)
   @ nLin, 198 Psay aSOlicita[nCtaFor, 18	]																																																		// Hora (Entrega)
   @ nLin, 204 Psay aSOlicita[nCtaFor, 12	]																																																		// Usuario entrega
   
   nLin++

			@ nLin, 022 Psay aSOlicita[nCtaFor, 16	]																																																		// Obs Solicita็ใo

			// Obs Encerramento
   GSA->(DbGoTo(aSOlicita[nCtaFor, 19	]))
   nLinMemo := MlCount(AllTrim(GSA->GSA_MOTIVO))   
   @nLin, 090 PSAY IIf(Empty(GSA->GSA_MOTIVO), Replicate(" ", 89), SUBSTR(MemoLine(GSA->GSA_MOTIVO,, 1), 1, 89))
   
   If Empty(GSA->GSA_MOTIVO)
   	@ nLin, 187 Psay IIf(Empty(aSOlicita[nCtaFor][08]), Space(TamSx3("GSA_DATRET")[1]), HS_DTOC(aSOlicita[nCtaFor][08], 1)) 	// Retorno
   	@ nLin, 198 Psay aSOlicita[nCtaFor, 09	]																																																		// Hora (Retorno)
   	@ nLin, 204 Psay aSOlicita[nCtaFor, 13	]																																																		// Usuario Retorno
   Else
   	@ nLin, 187 Psay HS_DTOC(GSA->GSA_DATCAN, 1) 	// Data de encerramento
   	@ nLin, 198 Psay GSA->GSA_HORCAN														// Hora (Retorno)
   	@ nLin, 204 Psay GSA->GSA_NOMCAN														// Usuario Retorno
   EndIf
   // Imprime continuacao do campo Obs encerramento //
   If (nLinMemo > 1)
    nLin++
   	For nMemoFor := 2 To nLinMemo
					@nLin, 090 PSAY SUBSTR(MemoLine(GSA->GSA_MOTIVO,, nMemoFor), 1, 89)   
					nLin++
   	Next nMemoFor
   EndIf
   
   nLin++
			nTotMov++

  Next   
  
  @ nLin,00 Psay STR0030 + Transform(nTotMov, "@E 9,999")
  nLin++
  @ nLin,00 Psay Replicate("_", limite)
 endif 
 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldRc3 บAutor  ณEduardo Alves       บ Data ณ  02/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao dos campos (Parametros pergunta)      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldRc3()
	Local lRet 	:= .T.
	
	If 					(ReadVar() == "MV_PAR01") // Prontuario
		If !(lRet := HS_SeekRet("GSA", "MV_PAR01", 7, .F.,,,,, .T.))
			HS_MsgInf(STR0031, STR0027, STR0032) //"Nenhuma solicita็ใo encontrada para o prontuแrio informado."###"Aten็ใo"###"Valida็ใo dos Parametros"
		Else
			cGsaRegGer 	:= MV_PAR01
		EndIf
	ElseIf 	(ReadVar() == "MV_PAR02") // Codigo do endereco
		If !(lRet := HS_SeekRet("GSA", "MV_PAR01 + MV_PAR02", 7, .F.,,,,, .T.))
			HS_MsgInf(STR0033, STR0027, STR0032) //"Este endere็o nใo esta relacionando ao prontuแrio informado."###"Aten็ใo"###"Valida็ใo dos Parametros"
		EndIf
	EndIf
	
Return(lRet)
