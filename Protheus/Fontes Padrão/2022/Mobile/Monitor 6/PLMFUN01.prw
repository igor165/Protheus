User Function PLMFUN01()

// Indices extras para TFA
If PALMUSER->P_SISTEMA=="2" 
	aadd( aIndFk, { 305,"AB9"  + cEmpAnt + "0", "AB9" + cEmpAnt + "02", "AB9_NUMOS+AB9_SEQ", "F"  } )  
	aadd( aIndFk, { 306,"ABB"  + cEmpAnt + "0", "ABB" + cEmpAnt + "02", "ABB_DTINI", "F"  } )  
	aadd( aIndFk, { 307,"ABB"  + cEmpAnt + "0", "ABB" + cEmpAnt + "03", "ABB_NUMOS+ABB_DTINI", "F"  } )  
	aadd( aIndFk, { 308,"SA1"  + cEmpAnt + "0", "SA1" + cEmpAnt + "02", "A1_NOME", "F"  } )  
	aadd( aIndFk, { 309,"SA2"  + cEmpAnt + "0", "SA2" + cEmpAnt + "02", "A2_NREDUZ", "F"  } )  
	aadd( aIndFk, { 310,"AAG"  + cEmpAnt + "0", "AAG" + cEmpAnt + "02", "AAG_DESCRI", "F"  } )  
	aadd( aIndFk, { 311,"AA5"  + cEmpAnt + "0", "AA5" + cEmpAnt + "02", "AA5_DESCRI", "F"  } )
	aadd( aIndFk, { 312,"SB1"  + cEmpAnt + "0", "SB1" + cEmpAnt + "02", "B1_DESC", "F"  } )
EndIf

If PALMUSER->P_SISTEMA=="3" 
   ConOut( "PALMJOB: Ponto de entrada ativo PLMFUN01, indices extras para o FDA" ) 
   // Indices Pronta entrega
   aadd( aIndFk, { 218,"HF2" + cEmpAnt + "0", "HF2" + cEmpAnt + "02", "F2_CLIENTE+F2_LOJA+F2_DOC", "F"  } )
   aadd( aIndFk, { 219,"HB6" + cEmpAnt + "0", "HB6" + cEmpAnt + "02", "B6_DOC+B6_SERIE+DTOS(B6_DATA)", "F"  } )
   aadd( aIndFk, { 220,"HTR" + cEmpAnt + "0", "HTR" + cEmpAnt + "02", "TR_GRUPO+TR_PROD+TR_CLI+TR_LOJA", "F"  } )
   aadd( aIndFk, { 221,"HF1" + cEmpAnt + "0", "HF1" + cEmpAnt + "02", "F1_FORNECE+F1_LOJA", "F"  } )
   aadd( aIndFk, { 222,"HD1" + cEmpAnt + "0", "HD1" + cEmpAnt + "02", "D1_DOC+D1_NFORI+D1_ITEMORI+D1_COD", "F"  } )
EndIf

// Indices extras para PMS
If PALMUSER->P_SISTEMA=="4" 

EndIf


Return Nil