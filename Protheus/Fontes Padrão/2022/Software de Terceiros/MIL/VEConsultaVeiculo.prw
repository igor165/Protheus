#include "totvs.ch"

#define lDebug .f.

STATIC cSGBD := TcGetDb()

Function VEConsultaVeiculo()
Return

Class VEConsultaVeiculo

	Data _cCamposRet // Campos que serão retornados na Query
	Data _cCamposQuery // Campos que serão utilizados na Query
	Data _cVisualiza // "0" - Novos / "1" - Usados / "2" - Todos
	Data _cMarcas

	Data _cMarNovos
	Data _cMarUsados
	Data _cMarWhere

	Data _lFilNovoUsado

	Data _oSQLHelper
	Data _oFilialHelper

	Data _lVendidoSitVei
	Data _lVazioSitVei

	//Data _lSetDiasEstoque

	Data _lSoEstoque
	Data _lImobilizado

	Data _lAddColAtend
	Data _lAddColPedido
	Data _lMovEntrada
	Data _lMovSaida
	Data _lPedCompra

	Method New() CONSTRUCTOR

	Method SetCamposRet()
	Method SetCamposQuery()
	//Method SetDiasEstoque()

	Method SetSoEstoque()
	Method SetImobilizado()
	Method SetMovEntrada()
	Method SetMovSaida()
	Method SetPedCompra()
	Method SetVendidoSitVei()
	Method SetVazioSitVei()

	Method GetSoEstoque()
	Method GetImobilizado()
	Method GetMovEntrada()
	Method GetMovSaida()
	Method GetPedCompra()


	Method SetMarcas()
	Method SetMarcasVAI()

	Method GetMarcas() 

	Method GetQuery()

	Method GetCamposQuery()

	Method ColAtendimento()
	Method ColPedido()

EndClass

Method New() Class VEConsultaVeiculo
	Self:_cVisualiza := "2"
	self:_cMarcas := ""
	self:_lSoEstoque := .f.
	self:_lImobilizado := .f.
	self:_lAddColAtend := .f.
	self:_lAddColPedido := .f.
	self:_lMovEntrada := .f.
	self:_lMovSaida := .f.
	self:_lPedCompra := .f.
	self:_oSQLHelper := DMS_SQLHelper():New()
	self:_oFilialHelper := DMS_FilialHelper():New()
	self:_cCamposRet := "VV1_FILENT, VV1_CODMAR, VE1_DESMAR, VV1_MODVEI, VV1_SEGMOD " + IIF( VV2->(ColumnPos("VV2_OPCION")) <> 0 , ", VV2_OPCION, VV2_COREXT, VV2_CORINT" , "" ) + ", VV1_CHAINT, VV1_CHASSI, VV1_FABMOD, VV1_FABANO, VV1_FABMES, VV1_COMVEI, VV1_SITVEI, PEDMONT , BLOQ"
	self:_cCamposQuery := "VV1_FILENT, VV1_CODMAR, VE1_DESMAR, VV1_MODVEI, VV1_SEGMOD " + IIF( VV2->(ColumnPos("VV2_OPCION")) <> 0 , ", VV2_OPCION, VV2_COREXT, VV2_CORINT" , "" ) + ", VV1_CHAINT, VV1_CHASSI, VV1_FABMOD, VV1_FABANO, VV1_FABMES, VV1_COMVEI, VV1_SITVEI "
	self:_lVendidoSitVei := .t.
	self:_lVazioSitVei := .t.

	self:SetMarcasVAI()
Return self

Method SetCamposRet(cCampos) Class VEConsultaVeiculo
	self:_cCamposRet := cCampos
Return

Method SetCamposQuery(cCampos) Class VEConsultaVeiculo
	self:_cCamposQuery := cCampos
Return

//Method SetDiasEstoque(lRetDias) Class VEConsultaVeiculo
//	self:_lSetDiasEstoque := lRetDias
//Return

Method SetSoEstoque(_lSoEstoque) Class VEConsultaVeiculo
	self:_lSoEstoque := _lSoEstoque
Return

Method SetImobilizado(_lImobilizado) Class VEConsultaVeiculo
	self:_lImobilizado := _lImobilizado
Return

Method SetMovEntrada(_lMovEntrada) Class VEConsultaVeiculo
	self:_lMovEntrada := _lMovEntrada
Return

Method SetMovSaida(_lMovSaida) Class VEConsultaVeiculo
	self:_lMovSaida := _lMovSaida
Return

Method SetPedCompra(_lPedCompra) Class VEConsultaVeiculo
	self:_lPedCompra := _lPedCompra
Return

Method SetVendidoSitVei(_lVendidoSitVei) Class VEConsultaVeiculo
	self:_lVendidoSitVei := _lVendidoSitVei
Return

Method SetVazioSitVei(_lVazioSitVei) Class VEConsultaVeiculo
	self:_lVazioSitVei := _lVazioSitVei
Return

Method GetSoEstoque() Class VEConsultaVeiculo
Return self:_lSoEstoque

Method GetImobilizado() Class VEConsultaVeiculo
Return self:_lImobilizado

Method GetMovEntrada() Class VEConsultaVeiculo
Return self:_lMovEntrada

Method GetMovSaida() Class VEConsultaVeiculo
Return self:_lMovSaida

Method GetPedCompra() Class VEConsultaVeiculo
Return self:_lPedCompra

Method SetMarcas(cAuxMarcas) Class VEConsultaVeiculo
	If Empty(cAuxMarcas)
		self:_cMarcas := ""
	Else
		self:_cMarcas := FormatIN(cAuxMarcas, ",")
	EndIf
Return

Method SetMarcasVAI() Class VEConsultaVeiculo
	self:_cMarNovos  := VAI->VAI_MARNOV
	self:_cMarUsados := VAI->VAI_MARUSA
Return

Method GetMarcas() Class VEConsultaVeiculo
	Local cSQLMarca := "TVE1"
	Local cWhereMarca

	AtuWhereMarca()
	cWhereMarca := self:_cMarWhere

	aMar := {}

	BeginSQL Alias cSQLMarca
		
		SELECT VE1.VE1_CODMAR , VE1.VE1_DESMAR 
			FROM 
				%table:VE1% VE1
		WHERE 
			VE1.VE1_FILIAL = %xFilial:VE1% 
			%exp:cWhereMarca% 
			AND VE1.%notDel% 
		ORDER BY VE1.VE1_CODMAR

	EndSql
	While !( cSQLMarca )->( Eof() )
		aAdd(aMar,{lAux,( cSQLMarca )->( VE1_CODMAR ),( cSQLMarca )->( VE1_DESMAR )})
		( cSQLMarca )->( DbSkip() )
	EndDo
	( cSQLMarca )->( DbCloseArea() )
	//

Return

Method GetCamposQuery() Class VEConsultaVeiculo
Return self:_cCamposQuery

Method ColAtendimento(_lAddColAtend) Class VEConsultaVeiculo
	self:_lAddColAtend := _lAddColAtend
Return

Method ColPedido(_lAddColPedido) Class VEConsultaVeiculo
	self:_lAddColPedido := _lAddColPedido
Return



Method GetQuery() Class VEConsultaVeiculo
	Local cQuery
	Local cFuncStr := self:_oSQLHelper:CompatFunc("SUBSTR")
	Local cSGBD := TcGetDb()

	Local cStrConvData
	Local aStrConv := {}

	//Local cQAlSQL := "TTMPVV1"

	// VV1_SITVEI
	// 0=Estoque
	// 1=Vendido
	// 2=Em Transito
	// 3=Remessa
	// 4=Consignado
	// 5=Transferido
	// 6=Reservado
	// 7=Progresso
	// 8=Pedido
	// 9=Requisitado OS


	If "ORACLE" $ cSGBD
		aStrConv := {;
			"'20'" , cFuncStr + "(VV1_DTHVAL,7,2)" , "'-'" ,;
			cFuncStr + "(VV1_DTHVAL,4,2)" , "'-'" ,;
			cFuncStr + "(VV1_DTHVAL,1,2)" , "' '" ,;
			cFuncStr + "(VV1_DTHVAL,10,2)" , "':'" ,; 
			cFuncStr + "(VV1_DTHVAL,12,2)" , "':59'";
		}
		cStrConvData := self:_oSQLHelper:Concat(aStrConv)
		cStrConvData := self:_oSQLHelper:ConvToDate(cStrConvData,,'YYYY-MM-DD HH24:MI:SS')
	Else
		aStrConv := {;
			"'20'" , cFuncStr + "(VV1_DTHVAL,7,2)" ,;
			cFuncStr + "(VV1_DTHVAL,4,2)" ,;
			cFuncStr + "(VV1_DTHVAL,1,2)" , "' '" ,;
			cFuncStr + "(VV1_DTHVAL,10,2)" , "':'" ,; 
			cFuncStr + "(VV1_DTHVAL,12,2)" , "':59'";
		}
		cStrConvData := self:_oSQLHelper:Concat(aStrConv)
		cStrConvData := self:_oSQLHelper:ConvToDate(cStrConvData,,'YYYYMMDD HH24:MI:SS')
	EndIf

	//FWAliasInDic

	//cQuery := "SELECT DISTINCT VV1.R_E_C_N_O_ VV1RECNO , VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_TIPVEI , VV1.VV1_ESTVEI , VV1.VV1_SITVEI , VV1.VV1_TRACPA , VV1.VV1_CODMAR , VV2.VV2_GRUMOD , VVR.VVR_DESCRI "
	//If lVV1_DTFATT // Dias de Transito
	//	cQuery += ", VV1.VV1_DTFATT "
	//EndIf
	//cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
	//cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
	//cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
	//cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_SITVEI IN ('0','2','3') AND VV1.D_E_L_E_T_=' '"

	//				 " AND VV1.VV1_FILENT = '" + cFilAnt + "'" +;
	//				 " AND VV1.VV1_ESTVEI = '0' " +; // 
	//				 " AND ( ( VV1.VV1_SITVEI='0' AND VV1.VV1_TRACPA<>' ' ) OR VV1.VV1_SITVEI IN ('2','8') )" +;
 	// 0=Estoque
	// 2=Em Transito
	// 3=Remessa
	// 4=Consignado
	// 5=Transferido
	// 6=Reservado
	// 7=Progresso
	// 8=Pedido

//					 " AND VV1.VV1_IMOBI <> '1' " +;
//		 " WHERE " +;
//		 	"(" +;
//				" ( TEMP.VV1_RESERV IN ('1','3') AND SYSDATE <= TEMP.DTHVAL ) " +;
//				" OR " +;
//				 "TEMP.VV1_RESERV NOT IN ('1','3') " +;
//			")" +;
//			" AND TEMP.BLOQ = ' '" +;
//	" ORDER BY TEMP.VV1_FABANO DESC, TEMP.VV1_FABMES, TEMP.VV1_CHASSI "
//					" VV1_RESERV, VV1_CODMAR, VV1_MODVEI, VV1_SEGMOD, VV1_CHAINT, VV1_CHASSI, VV1_FABMOD, VV1_FABANO, VV1_FABMES, VV1_COMVEI "
//


If "ORACLE" $ cSGBD
	aStrConv := {;
		"'20'" , cFuncStr + "(VVF_DTHEMI, 7, 2)" , "'-'" ,;
		cFuncStr + "(VVF_DTHEMI, 4, 2)" , "'-'" ,;
		cFuncStr + "(VVF_DTHEMI, 1, 2)" , "' '" ,;
		cFuncStr + "(VVF_DTHEMI, 10, 8)" ;
		}
Else
	aStrConv := {;
			"'20'" , cFuncStr + "(VVF_DTHEMI,7,2)" ,;
			cFuncStr + "(VVF_DTHEMI,4,2)" ,;
			cFuncStr + "(VVF_DTHEMI,1,2)" ,;
			cFuncStr + "(VVF_DTHEMI,10,8)";
		}
EndIf

cQueryUMov := self:_oSQLHelper:TOPFunc( ;
	"SELECT VVF_DATMOV, " +;
			self:_oSQLHelper:Concat(aStrConv) + " DTHEMI " +;
		" FROM " + RetSQLName("VVF") + " VVF " +;
		" INNER JOIN " + RetSQLName("VVG") + " VVG " +;
				" ON VVG.VVG_FILIAL = VVF.VVF_FILIAL" +;
				" AND VVG.VVG_TRACPA = VVF.VVF_TRACPA" +;
				" AND VVG.D_E_L_E_T_ = ' '" +;
		" WHERE VVG.VVG_CHAINT = VV1.VV1_CHAINT" +;
			" AND VVF.VVF_SITNFI <> '0'" +;
			" AND VVF.VVF_OPEMOV = '0'" +;
			" AND VVF.D_E_L_E_T_ = ' '" +;
			" ORDER BY 2 DESC" , 1 )

	cQuery := ;
		"SELECT " + self:_cCamposRet + ;
  		 " FROM ( " +;
				"SELECT " +;
					" CASE VV1.VV1_DTHVAL " +;
						" WHEN ' ' THEN NULL " +;
						" ELSE " + cStrConvData +;
					" END DTHVAL "

				// Pedido venda Montadora 
				If FWAliasInDic("VRJ")
					cQuery += ;
					", CASE " +;
						" WHEN EXISTS ( " +;
										" SELECT VRKCONS.VRK_PEDIDO" +;
										" FROM " + RetSqlName("VRK") + " VRKCONS " +;
												" JOIN " + RetSqlName("VRJ") + " VRJCONS " +;
													"  ON VRJCONS.VRJ_FILIAL = VRKCONS.VRK_FILIAL " +;
													" AND VRJCONS.VRJ_PEDIDO = VRKCONS.VRK_PEDIDO " +;
													" AND ( VRJCONS.VRJ_STATUS NOT IN ('C', 'R', 'F') OR ( VRJCONS.VRJ_STATUS = 'F' AND VRKCONS.VRK_NUMTRA = ' ' ) ) " +;
													" AND VRJCONS.D_E_L_E_T_ = ' ' " +;
										" WHERE VRKCONS.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
										" AND VRKCONS.VRK_CHAINT = VV1.VV1_CHAINT" +;
										" AND VRKCONS.VRK_CANCEL IN ('0',' ') " +;
										" AND VRKCONS.D_E_L_E_T_ = ' ' ) " +;
						" THEN 1 " +; // Veiculo em Pedido de Venda Montadora (ATACADO)
						" ELSE 0 " +; 
					" END AS PEDMONT "
				Else
					cQuery += ", 0 AS PEDMONT "
				EndIf

				// Atendimento 
				cQuery += ;
					", CASE " +;
						" WHEN EXISTS ( " +;
							"SELECT VVA.R_E_C_N_O_  " +;
							  " FROM " + RetSQLName("VVA") + " VVA " +;
									"JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = VVA.VVA_FILIAL AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' ' " +;
									"JOIN " + RetSQLName("VV9") + " VV9 ON VV9.VV9_FILIAL = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_ = ' ' " +;
							 " WHERE VVA.VVA_FILIAL = '" + xFilial("VVA") + "'" + ;
								" AND VVA.VVA_CHAINT = VV1.VV1_CHAINT " +;
								" AND VVA.D_E_L_E_T_ = ' '" +;
								" AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D') )" +;
						" THEN 1 " +; // Veiculo em Atendimento
						" ELSE 0 " +; 
					" END AS ATEND "

				// Bloqueio de Veiculo 
				cQuery += ;
					", CASE " +;
						" WHEN EXISTS (" +;
										" SELECT VB0.R_E_C_N_O_ " +;
										  " FROM " + RetSqlName("VB0") + " VB0" +;
										 " WHERE VB0_FILIAL = '" + xFilial("VB0") + "' " +;
											" AND VB0.VB0_CHAINT = VV1.VV1_CHAINT" +;
											" AND VB0.VB0_DATDES = ' ' " +;
											" AND ( VB0.VB0_DATVAL > '" + DtoS(dDataBase) + "' OR ( VB0.VB0_DATVAL = '" + DtoS(dDataBase) + "' AND VB0.VB0_HORVAL > '" + StrTran(Left(Time(),5),":","") + "' ))" +;
											" AND VB0.D_E_L_E_T_ = ' ' ) " +;
						" THEN 1 " +; // Veiculo Bloqueado
						" ELSE 0 " +;
					" END AS BLOQ "
				//

				// Reserva Temporaria 
				cQuery += ;
					", CASE " +;
						" WHEN EXISTS (" +;
										" SELECT VRE.R_E_C_N_O_ " +;
										  " FROM " + RetSQLName("VRE") + " VRE " +;
										 " WHERE VRE.VRE_FILIAL = '" + xFilial("VRE") + "' " +;
											" AND VRE.VRE_CHAINT = VV1.VV1_CHAINT " +;
											" AND VRE.VRE_STATUS = '1' " +;
											" AND ( VRE.VRE_DATDES > '" + DtoS(dDataBase) + "' OR ( VRE.VRE_DATDES = '" + DtoS(dDataBase) + "' AND VRE.VRE_HORDES > '" + StrTran(Left(Time(),5),":","") + "' ))" +;
											" AND VRE.D_E_L_E_T_ = ' ' ) " +;
						" THEN 1 " +; // Reserva Temporaria
						" ELSE 0 " +;
					" END AS RESTEMP "
				//
				If self:_lAddColAtend
					cQuery += ", COALESCE("

					If 'MSSQL' $ cSGBD
						cQuery += " ( STUFF( ( SELECT VVA.VVA_NUMTRA + '/' "
					ElseIf 'ORACLE' $ cSGBD
						cQuery += " ( SELECT LISTAGG (VVA.VVA_NUMTRA, '/') WITHIN GROUP ( ORDER BY	VVA.VVA_NUMTRA	) COLATEND"
					EndIf

					cQuery += ;
							" FROM " + RetSQLName("VVA") + " VVA " +;
								"JOIN " + RetSQLName("VV9") + " VV9 ON VV9.VV9_FILIAL = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_ = ' ' " +;
							" WHERE VVA.VVA_FILIAL = '" + xFilial("VVA") + "'" +;
							" AND VVA.VVA_CHAINT = VV1.VV1_CHAINT " +;
							" AND VVA.D_E_L_E_T_ = ' '" +;
							" AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D') "
					
					If 'MSSQL' $ cSGBD
						cQuery += " FOR XML PATH ('')),1,1,'') "
					EndIf

					cQuery += ;
						" )" +;
						", '" + Space(TamSX3("VVA_NUMTRA")[1]) + "'" +;
					") COLATEND "
				Else
					cQuery += ", ' ' COLATEND "
				EndIf

				If FWAliasInDic("VRJ") .and. self:_lAddColPedido
					cQuery += ", COALESCE("

					If 'MSSQL' $ cSGBD
						cQuery += " ( STUFF( ( SELECT VRKLST.VRK_PEDIDO + '/' "
					ElseIf 'ORACLE' $ cSGBD
						cQuery += " ( SELECT LISTAGG (VRKLST.VRK_PEDIDO, '/') WITHIN GROUP ( ORDER BY VRKLST.VRK_PEDIDO ) COLPEDIDO"
					EndIf

					cQuery +=;
							" FROM " + RetSqlName("VRK") + " VRKLST " +;
									" JOIN " + RetSqlName("VRJ") + " VRJLST " +;
										"  ON VRJLST.VRJ_FILIAL = VRKLST.VRK_FILIAL " +;
										" AND VRJLST.VRJ_PEDIDO = VRKLST.VRK_PEDIDO " +;
										" AND ( VRJLST.VRJ_STATUS NOT IN ('C', 'R', 'F') OR ( VRJLST.VRJ_STATUS = 'F' AND VRKLST.VRK_NUMTRA = ' ' ) ) " +;
										" AND VRJLST.D_E_L_E_T_ = ' ' " +;
							" WHERE VRKLST.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
							" AND VRKLST.VRK_CHAINT = VV1.VV1_CHAINT" +;
							" AND VRKLST.VRK_CANCEL IN ('0',' ') " +;
							" AND VRKLST.D_E_L_E_T_ = ' ' "

					If 'MSSQL' $ cSGBD
						cQuery += " FOR XML PATH ('')),1,1,'') "
					EndIf

					cQuery += ;
						" )" +;
						", '" + Space(TamSX3("VRK_PEDIDO")[1]) + "'" +;
					") COLPEDIDO "
				Else
					cQuery += ", ' ' COLPEDIDO "
				EndIf

				// Ultima Compra

				// Dias em Estoque
				If "ORACLE" $ cSGBD
					cQuery += ",( SELECT COALESCE( VVF_DATMOV, '        ') ULTMOV FROM (" + cQueryUMov + ") ) ULTMOV "
					cQuery += ",( SELECT COALESCE( TRUNC(SYSDATE - TO_DATE(VVF_DATMOV, 'YYYYMMDD'), 0), 0 ) DIAESTQ FROM (" + cQueryUMov + ") ) DIAESTQ "
				ElseIf "MSSQL" $ cSGBD
					cQuery += ",( SELECT COALESCE( VVF_DATMOV, '        ') ULTMOV FROM (" + cQueryUMov + ") AS TMPULTMOV ) ULTMOV "
					cQuery += ",( SELECT COALESCE( DATEDIFF( DAY, CONVERT(DATETIME, VVF_DATMOV) , GETDATE() ) , 0) DIAESTQ FROM (" + cQueryUMov + ") AS TMPDIAEST ) DIAESTQ "
				EndIf
				//

				cQuery += ", " + self:_cCamposQuery

				//cQuery += ", VV1.* ,VE1.* ,VV2.* ,VVC.* "
				//
				//If self:_lMovEntrada
				//	cQuery += ", VVF.*, VVG.*"
				//EndIf
				//
				//If self:_lMovSaida
				//	cQuery += ", VV0.*, VVA.*"
				//EndIf
				
				If VV2->(ColumnPos("VV2_OPCION")) <> 0
					cQuery += ;
						", COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION " +;
						", COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT " +;
						", COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT "
				EndIf
				
				cQuery += ;
					" FROM " + RetSqlName("VV1") + " VV1 " +;
						" INNER JOIN " + RetSqlName("VE1") + " VE1 " +;
								"  ON VE1.VE1_FILIAL = '" + xFilial("VE1") + "' " +;
								" AND VE1.VE1_CODMAR = VV1.VV1_CODMAR " +;
								" AND VE1.D_E_L_E_T_ = ' ' " +;
						" INNER JOIN " + RetSqlName("VV2") + " VV2 " +;
								"  ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " +;
								" AND VV2.VV2_CODMAR = VV1.VV1_CODMAR " +;
								" AND VV2.VV2_MODVEI = VV1.VV1_MODVEI " +;
								" AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD " +;
								" AND VV2.D_E_L_E_T_ = ' ' "

				If VV2->(ColumnPos("VV2_OPCION")) <> 0 
					cQuery += ;
						" LEFT JOIN " + RetSqlName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CHAVE = '066' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CHAVE = '067' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CHAVE = '068' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' ' "
				EndIf

				cQuery += ;
						" LEFT JOIN " + RetSqlName("VVC") + " VVC " +; 
								"  ON VVC.VVC_FILIAL = '" + xFilial("VVC") + "'" +;
								" AND VVC.VVC_CODMAR = VV1.VV1_CODMAR " +;
								" AND VVC.VVC_CORVEI = VV1.VV1_CORVEI " +;
								" AND VVC.D_E_L_E_T_ = ' ' "
								
				If self:_lMovEntrada
					cQuery += ;
						" LEFT JOIN " + RetSqlName("VVF") + " VVF " +; 
								"  ON VVF.VVF_FILIAL = VV1.VV1_FILENT " +;
								" AND VVF.VVF_TRACPA = VV1.VV1_TRACPA " +;
								" AND VVF.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VVG") + " VVG " +; 
								"  ON VVG.VVG_FILIAL = VVF.VVF_FILIAL " +;
								" AND VVG.VVG_TRACPA = VVF.VVF_TRACPA " +;
								" AND VVG.VVG_CHAINT = VV1.VV1_CHAINT " +;
								" AND VVG.D_E_L_E_T_ = ' ' "
				EndIf

				If self:_lMovSaida
					cQuery += ;
						" LEFT JOIN " + RetSqlName("VV0") + " VV0 " +; 
								"  ON VV0.VV0_FILIAL = VV1.VV1_FILSAI " +;
								" AND VV0.VV0_NUMTRA = VV1.VV1_NUMTRA " +;
								" AND VV0.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VVA") + " VVA " +; 
								"  ON VVA.VVA_FILIAL = VV0.VV0_FILIAL " +;
								" AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA " +;
								" AND VVA.VVA_CHAINT = VV1.VV1_CHAINT " +;
								" AND VVA.D_E_L_E_T_ = ' ' "
				EndIf

				If self:_lPedCompra
					cQuery += ;
						" LEFT JOIN " + RetSqlName("VQ0") + " VQ0 " +; 
								"  ON VQ0.VQ0_FILENT = VV1.VV1_FILENT " +;
								" AND VQ0.VQ0_CHAINT = VV1.VV1_CHAINT " +;
								" AND VQ0.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VJR") + " VJR " +; 
								"  ON VJR.VJR_FILIAL = VQ0.VQ0_FILIAL " +;
								" AND VJR.VJR_CODVQ0 = VQ0.VQ0_CODIGO " +;
								" AND VJR.D_E_L_E_T_ = ' ' "
				EndIf
				
				cQuery += ;
					"WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'" +;
					 " AND VV1.D_E_L_E_T_=' '"
	
	If self:_lSoEstoque
		cQuery += " AND VV1.VV1_ESTVEI = '0' " +;
					 " AND ( ( VV1.VV1_SITVEI='0' AND VV1.VV1_TRACPA<>' ' ) OR VV1.VV1_SITVEI IN ('2','8') )"
	EndIf
	If self:_lImobilizado == .f.
		cQuery += " AND VV1.VV1_IMOBI <> '1' "
	EndIf
	if ! self:_lVendidoSitVei
		cQuery += " AND VV1.VV1_SITVEI <> '1'"
	endif
	if ! self:_lVazioSitVei
		cQuery += " AND VV1.VV1_SITVEI <> ' '"
	endif

	cQuery += " ) TEMP "
	
	If lDebug
		CopytoClipBoard(cQuery)
		ConOut("   ")
		ConOut(cQueryUMov)
		ConOut("   ")
		ConOut(cQuery)
		ConOut("   ")
	EndIf

Return cQuery






Static Function AtuWhereMarca()
	Local cWhereMarca := ""

	If ! Empty(self:_cMarcas)
		cWhereMarca += " AND VE1.VE1_CODMAR IN " + self:_cMarcas
	EndIf
	
	If self:_cVisualiza == "0" .and. ! Empty(self:_cMarNovos)
		cWhereMarca += " AND " + self:_oSQLHelper:StrWithinAStr("'" + AllTrim(self:_cMarNovos) + "'" , "VE1.VE1_CODMAR")
	EndIf
	If self:_cVisualiza == "1" .and. ! Empty(self:_cMarUsados)
		cWhereMarca += " AND " + self:_oSQLHelper:StrWithinAStr("'" + AllTrim(self:_cMarUsados) + "'" , "VE1.VE1_CODMAR")
	EndIf

	If self:_cVisualiza == "2" .or. ( ! Empty(self:_cMarNovos) .and. ! Empty(self:_cMarUsados) )

		cWhereMarca += " AND ( "

		If ! Empty(self:_cMarNovos)
			cWhereMarca += self:_oSQLHelper:StrWithinAStr("'" + AllTrim(self:_cMarNovos) + "'" , "VE1.VE1_CODMAR")
		EndIf

		If ! Empty(self:_cMarUsados)
			cWhereMarca += IIf(! Empty(self:_cMarNovos) , " OR " , "" )
			cWhereMarca += self:_oSQLHelper:StrWithinAStr("'" + AllTrim(self:_cMarUsados) + "'" , "VE1.VE1_CODMAR")
		EndIf

		cWhereMarca += " ) "
	EndIf

	Self:_cMarWhere := cWhereMarca

Return