#include "protheus.ch"
#include "diotmex.ch"

static oTmpDiot
static oTmpDet
/*                                                               	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTMEX   บAutor  ณLuciana Pires       บFecha ณ 01/11/2008   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณCria um arquivo temporario com as informacoes necessarias    บฑฑ
ฑฑบ          ณpara a geracao do arquivo txt para a DIOT - Mexico           บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑบParametrosณnFilIni    - Filial inicial a ser considerado para a operacaoบฑฑ
ฑฑบ          ณnFilFin    - Filial final a ser considerada para a operacao  บฑฑ
ฑฑบ          ณdDtInicial - Data inicial a ser considerada para a operacao  บฑฑ
ฑฑบ          ณdDtFinal   - Data inicial a ser considerada para a operacao  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณDIOT - MATA950 - Mexico                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณARodriguez  ณ12/04/12ณTETKTQณ-Impresion del resumen, ahora tambi้n       ณฑฑ
ฑฑณ            ณ        ณ      ณ muestra ventana de dialogo de impresi๓n    ณฑฑ  
ฑฑณLaura Medinaณ31/01/13ณTGNWPHณ No imprime el pais ni la nacionalidad en elณฑฑ
ฑฑณ            ณ        ณ      ณ archivo (.txt)                             ณฑฑ  
ฑฑณLaura Medinaณ17/04/13ณTHAKVYณ Agrupar los registros de proveedores       ณฑฑ
ฑฑณ            ณ        ณ      ณ Globales por tipo  de Operacion.           ณฑฑ  
ฑฑณLaura Medina|20/09/13|THVKUH| Cambio para que consolide el reporte por   ณฑฑ
ฑฑณ            |        |      | grupo de sucursales (por razon social).    ณฑฑ
ฑฑณJonathan glzณ30/12/16ณSERINN001ณSe modifica uso de tablas temporales por ณฑฑ
ฑฑณ            ณ        ณ     -881ณmotivo de limpieza de CTREE.             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DIOTMEX(cForIni, cLojaIni, cForFin, cLojaFin, dDtInicial, dDtFinal, cFiliDe, cFiliAte, cConsol)
Local cChave	:= ""
Local cChaveDet	:= ""
Local nX 		:= 0
Local nY 		:= 0
Local nI 		:= 0
Local nPropor	:= 0
Local nTotOper	:= 0     
Local aArea		:= {}
Local aEstru	:= {}   
Local aEstruD	:= {}   
Local aDetPag	:= {} 			//Detalhe das ordens de pagamento / titulos (funcao Marcello Gabriel)
Local aTrb		:= {}  
Local cOper03   := "PROV GLOBAL-SERVICIOS"     //LEMP(THAKVY)
Local cOper06   := "PROV GLOBAL-ARRENDAMIENTO"
Local cOper85   := "OTROS"  
Local cNamePro  := ""   
Local cCGC      := ""
Local cIDFiscal := ""     
Local cTIPODOC  := ""    
Local nProcFil  := 0
lOCAL aOrder    := {}

Private aTotaliz	:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	//Guarda os totais para o resumo das operacoes
Private cFiltroDIO	:= ""
Private bFiltroDIO	:= {||}
Private cFiltroDIT	:= ""
Private bFiltroDIT	:= {||}
Private aCpyFilsC   := {}        //Copia del arreglo de sucursales 

Default cForIni		:= ""
Default cLojaIni	:= ""
Default cForFin		:= ""
Default cLojaFin	:= ""
Default dDtInicial	:= Ctod("01/01" + Strzero(Year(dDatabase),4))
Default dDtFinal	:= Ctod("31/12" + Strzero(Year(dDatabase),4))   
Default cFiliDe		:= "01"
Default cFiliAte	:= "01" 
Default cConsol     := "0"    //0-No Consolida 1-Consolida              
  
aArea := GetArea()
cFiliDe  := cFilAnt
cFiliAte := cFilAnt
cConsol  := Substr(cConsol,1,1) 


DbSelectArea("SYA")
SYA->(DbSetOrder(1))
SYA->(dbGoTop())

If SYA->(DbSeek(xFilial("SYA")+"013")) .And. Empty(SYA->YA_SGLMEX) 
	
	Do While !SYA->(Eof())
		
		cCod := SYA->YA_CODGI
		RecLock("SYA",.F.)
		
		Do Case
			Case cCod == "013" //"Afganistแn"
				SYA->YA_SGLMEX 	:= "AD"  
				SYA->YA_NASCIO	:= "Afganistแn"
			Case cCod == "023" //"Alemania"
				SYA->YA_SGLMEX 	:= "DD"  
				SYA->YA_NASCIO	:= "Alemania"
			Case cCod == "017" //"Rep๚blica de Albania"
				SYA->YA_SGLMEX 	:= "AL"  
				SYA->YA_NASCIO	:= "Rep๚blica de Albania"
			Case cCod == "037" //"Principado de Andorra"
				SYA->YA_SGLMEX 	:= "AD"  
				SYA->YA_NASCIO	:= "Principado de Andorra"
			Case cCod == "040" //Rep๚blica de Angola
				SYA->YA_SGLMEX 	:= "AO"  
				SYA->YA_NASCIO	:= "Rep๚blica de Angola"
			Case cCod == "041" //Isla Anguilla
				SYA->YA_SGLMEX 	:= "AI"  
				SYA->YA_NASCIO	:= "Isla Anguilla"
			Case cCod == "043" //Antigua y Bermuda
				SYA->YA_SGLMEX 	:= "AG"  
				SYA->YA_NASCIO	:= "Antigua y Bermuda"
			Case cCod == "047" //Antillas Neerlandesas
				SYA->YA_SGLMEX 	:= "AN"  
				SYA->YA_NASCIO	:= "Antillas Neerlandesas"
			Case cCod == "053" //Arabia Saudita
				SYA->YA_SGLMEX 	:= "SA"  
				SYA->YA_NASCIO	:= "Arabia Saudita"
			Case cCod == "059" //Argelia
				SYA->YA_SGLMEX 	:= "DZ"  
				SYA->YA_NASCIO	:= "Argelia"
			Case cCod == "063" //Argentina
				SYA->YA_SGLMEX 	:= "AR"  
				SYA->YA_NASCIO	:= "Argentina"
			Case cCod == "065" //Aruba
				SYA->YA_SGLMEX 	:= "AW"  
				SYA->YA_NASCIO	:= "Aruba"
			Case cCod == "069" //Australia
				SYA->YA_SGLMEX 	:= "AU"  
				SYA->YA_NASCIO	:= "Australia"
			Case cCod == "072" //Austria
				SYA->YA_SGLMEX 	:= "AT"  
				SYA->YA_NASCIO	:= "Austria"
			Case cCod == "077" //Commonwealth de las Bahamas
				SYA->YA_SGLMEX 	:= "BS"  
				SYA->YA_NASCIO	:= "Commonwealth de las Bahamas"
			Case cCod == "080" //Estado de Bahrein
				SYA->YA_SGLMEX 	:= "BH"  
				SYA->YA_NASCIO	:= "Estado de Bahrein"
			Case cCod == "081" //Bangladesh
				SYA->YA_SGLMEX 	:= "BD"  
				SYA->YA_NASCIO	:= "Bangladesh"
			Case cCod == "083" //Barbados
				SYA->YA_SGLMEX 	:= "BB"  
				SYA->YA_NASCIO	:= "Barbados"
			Case cCod == "087" //B้lgica
				SYA->YA_SGLMEX 	:= "BE"  
				SYA->YA_NASCIO	:= "B้lgica"
			Case cCod == "088" //Belice
				SYA->YA_SGLMEX 	:= "BL" 
				SYA->YA_NASCIO	:= "Belice"
			Case cCod == "229" //Benin
				SYA->YA_SGLMEX 	:= "BJ"
				SYA->YA_NASCIO	:= "Benin"
			Case cCod == "090" //Bermudas
				SYA->YA_SGLMEX 	:= "BM"
				SYA->YA_NASCIO	:= "Bermudas"
			Case cCod == "097" //Bolivia
				SYA->YA_SGLMEX 	:= "BO"
				SYA->YA_NASCIO	:= "Bolivia"
			Case cCod == "101" //Botswana
				SYA->YA_SGLMEX 	:= "BW"
				SYA->YA_NASCIO	:= "Botswana"
			Case cCod == "105" //Brasil
				SYA->YA_SGLMEX 	:= "BR"
				SYA->YA_NASCIO	:= "Brasil"
			Case cCod == "108" //Brunei Darussalam
				SYA->YA_SGLMEX 	:= "BN"
				SYA->YA_NASCIO	:= "Brunei Darussalam"
			Case cCod == "108" //Brunei Darussalam
				SYA->YA_SGLMEX 	:= "BN"
				SYA->YA_NASCIO	:= "Brunei Darussalam"
			Case cCod == "111" //Bulgaria
				SYA->YA_SGLMEX 	:= "BG"
				SYA->YA_NASCIO	:= "Bulgaria"
			Case cCod == "031" .Or. cCod == "310" //Burkina Faso
				SYA->YA_SGLMEX 	:= "BF"
				SYA->YA_NASCIO	:= "Burkina Faso"
			Case cCod == "115" //Burundi
				SYA->YA_SGLMEX 	:= "BI"
				SYA->YA_NASCIO	:= "Burundi"
			Case cCod == "119" //Buthan
				SYA->YA_SGLMEX 	:= "BT"
				SYA->YA_NASCIO	:= "Buthan"
			Case cCod == "127" //Rep๚blica de Cabo Verde
				SYA->YA_SGLMEX 	:= "CV"
				SYA->YA_NASCIO	:= "Rep๚blica de Cabo Verde"
			Case cCod == "145" //Camer๚n
				SYA->YA_SGLMEX 	:= "CM"
				SYA->YA_NASCIO	:= "Camer๚n"
			Case cCod == "149" //Canadแ
				SYA->YA_SGLMEX 	:= "CA"
				SYA->YA_NASCIO	:= "Canadแ"
			Case cCod == "151" //Islas Canarias
				SYA->YA_SGLMEX 	:= "CD"
				SYA->YA_NASCIO	:= "Islas Canarias"
			Case cCod == "137" //Islas Caimแn
				SYA->YA_SGLMEX 	:= "KY"
				SYA->YA_NASCIO	:= "Islas Caimแn"
			Case cCod == "788" //Chad
				SYA->YA_SGLMEX 	:= "TD"
				SYA->YA_NASCIO	:= "Chad"
			Case cCod == "158" //Chile
				SYA->YA_SGLMEX 	:= "CL"
				SYA->YA_NASCIO	:= "Chile"
			Case cCod == "160" //China
				SYA->YA_SGLMEX 	:= "CN"
				SYA->YA_NASCIO	:= "China"
			Case cCod == "163" //Rep๚blica de Chipre
				SYA->YA_SGLMEX 	:= "CY"
				SYA->YA_NASCIO	:= "Rep๚blica de Chipre"
			Case cCod == "163" //Rep๚blica de Chipre
				SYA->YA_SGLMEX 	:= "CY"
				SYA->YA_NASCIO	:= "Rep๚blica de Chipre"
			Case cCod == "511" //Isla de Christmas
				SYA->YA_SGLMEX 	:= "CE"
				SYA->YA_NASCIO	:= "Isla de Christmas"
			Case cCod == "165" //Isla de Cocos o Kelling
				SYA->YA_SGLMEX 	:= "CC"
				SYA->YA_NASCIO	:= "Isla de Cocos o Kelling"
			Case cCod == "169" //Colombia
				SYA->YA_SGLMEX 	:= "CO"
				SYA->YA_NASCIO	:= "Colombia"
			Case cCod == "173" //Comoros
				SYA->YA_SGLMEX 	:= "KM"
				SYA->YA_NASCIO	:= "Comoros"
			Case cCod == "888" .Or. cCod == "177" //Congo
				SYA->YA_SGLMEX 	:= "CG"
				SYA->YA_NASCIO	:= "Congo"
			Case cCod == "183" //Islas Cook
				SYA->YA_SGLMEX 	:= "CK"
				SYA->YA_NASCIO	:= "Islas Cook"
			Case cCod == "187" //Rep๚blica Democrแtica de Corea
				SYA->YA_SGLMEX 	:= "KP
				SYA->YA_NASCIO	:= "Rep๚blica Democrแtica de Corea"
			Case cCod == "190" //Rep๚blica de Corea
				SYA->YA_SGLMEX 	:= "KR"
				SYA->YA_NASCIO	:= "Rep๚blica de Corea"
			Case cCod == "193" //Costa de Marfil
				SYA->YA_SGLMEX 	:= "CI"
				SYA->YA_NASCIO	:= "Costa de Marfil"
			Case cCod == "196" //Rep๚blica de Costa Rica
				SYA->YA_SGLMEX 	:= "CR"
				SYA->YA_NASCIO	:= "Rep๚blica de Costa Rica"
			Case cCod == "199" //Cuba
				SYA->YA_SGLMEX 	:= "CU"
				SYA->YA_NASCIO	:= "Cuba"
			Case cCod == "232" //Dinamarca
				SYA->YA_SGLMEX 	:= "DK"
				SYA->YA_NASCIO	:= "Dinamarca"
			Case cCod == "783" //Rep๚blica de Djibouti
				SYA->YA_SGLMEX 	:= "DJ"
				SYA->YA_NASCIO	:= "Rep๚blica de Djibouti"
			Case cCod == "235" //Commonwealth de Dominica
				SYA->YA_SGLMEX 	:= "DN"
				SYA->YA_NASCIO	:= "Commonwealth de Dominica"
			Case cCod == "240" //Egipto
				SYA->YA_SGLMEX 	:= "EG"
				SYA->YA_NASCIO	:= "Egipto"
			Case cCod == "687" //El Salvador
				SYA->YA_SGLMEX 	:= "SV"
				SYA->YA_NASCIO	:= "El Salvador"
			Case cCod == "244" //Emiratos Arabes Unidos
				SYA->YA_SGLMEX 	:= "AE"
				SYA->YA_NASCIO	:= "Emiratos Arabes Unidos"
			Case cCod == "239" //Ecuador
				SYA->YA_SGLMEX 	:= "EC"
				SYA->YA_NASCIO	:= "Ecuador"
			Case cCod == "247" .Or. cCod == "791" .Or. cCod == "790" //Rep๚blica Checa y Rep๚blica Eslovaca
				SYA->YA_SGLMEX 	:= "CS"
				SYA->YA_NASCIO	:= "Rep๚blica Checa y Rep๚blica Eslovaca"
			Case cCod == "245" //Espa๑a
				SYA->YA_SGLMEX 	:= "ES"
				SYA->YA_NASCIO	:= "Espa๑a"
			Case cCod == "249" //Estados Unidos de Am้rica
				SYA->YA_SGLMEX 	:= "US"
				SYA->YA_NASCIO	:= "Estados Unidos de Am้rica"
			Case cCod == "253" //Etiopํa
				SYA->YA_SGLMEX 	:= "ET"
				SYA->YA_NASCIO	:= "Etiopํa"
			Case cCod == "255" //Islas Malvinas
				SYA->YA_SGLMEX 	:= "FK"
				SYA->YA_NASCIO	:= "Islas Malvinas"
			Case cCod == "870" //Fiji
				SYA->YA_SGLMEX 	:= "FJ"
				SYA->YA_NASCIO	:= "Fiji"
			Case cCod == "267" //Filipinas
				SYA->YA_SGLMEX 	:= "PH"
				SYA->YA_NASCIO	:= "Filipinas"
			Case cCod == "271" //Finlandia
				SYA->YA_SGLMEX 	:= "FI"
				SYA->YA_NASCIO	:= "Finlandia"
			Case cCod == "271" //Finlandia
				SYA->YA_SGLMEX 	:= "FI"
				SYA->YA_NASCIO	:= "Finlandia"
			Case cCod == "161" //Taiwแn
				SYA->YA_SGLMEX 	:= "TW"
				SYA->YA_NASCIO	:= "Taiwแn"
			Case cCod == "275" //Francia
				SYA->YA_SGLMEX 	:= "FR"
				SYA->YA_NASCIO	:= "Francia"
			Case cCod == "281" //Gab๓n
				SYA->YA_SGLMEX 	:= "GA"
				SYA->YA_NASCIO	:= "Gab๓n"
			Case cCod == "285" //Gambia
				SYA->YA_SGLMEX 	:= "GM"
				SYA->YA_NASCIO	:= "Gambia"
			Case cCod == "289" //Ghana
				SYA->YA_SGLMEX 	:= "GH"
				SYA->YA_NASCIO	:= "Ghana"
			Case cCod == "293" //Gibraltar
				SYA->YA_SGLMEX 	:= "GI"
				SYA->YA_NASCIO	:= "Gibraltar"
			Case cCod == "297" //Granada
				SYA->YA_SGLMEX 	:= "GD"
				SYA->YA_NASCIO	:= "Granada"
			Case cCod == "297" //Granada
				SYA->YA_SGLMEX 	:= "GD"
				SYA->YA_NASCIO	:= "Granada"
			Case cCod == "301" //Grecia
				SYA->YA_SGLMEX 	:= "GR"
				SYA->YA_NASCIO	:= "Grecia"
			Case cCod == "305" //Groenlandia
				SYA->YA_SGLMEX 	:= "GJ"
				SYA->YA_NASCIO	:= "Groenlandia"
			Case cCod == "309" //Guadalupe
				SYA->YA_SGLMEX 	:= "GP"
				SYA->YA_NASCIO	:= "Guadalupe"
			Case cCod == "313" //Guam
				SYA->YA_SGLMEX 	:= "GU"
				SYA->YA_NASCIO	:= "Guam"
			Case cCod == "317" //Guatemala
				SYA->YA_SGLMEX 	:= "GT"
				SYA->YA_NASCIO	:= "Guatemala"
			Case cCod == "337" //Rep๚blica de Guyana
				SYA->YA_SGLMEX 	:= "GY"
				SYA->YA_NASCIO	:= "Rep๚blica de Guyana"
			Case cCod == "325" //Guyana Francesa
				SYA->YA_SGLMEX 	:= "GF"
				SYA->YA_NASCIO	:= "Guyana Francesa"
			Case cCod == "329" //Guinea
				SYA->YA_SGLMEX 	:= "GN"
				SYA->YA_NASCIO	:= "Guinea"
			Case cCod == "334" //Guinea Bissau
				SYA->YA_SGLMEX 	:= "GW"
				SYA->YA_NASCIO	:= "Guinea Bissau"
			Case cCod == "331" //Guinea Ecuatorial
				SYA->YA_SGLMEX 	:= "GQ"
				SYA->YA_NASCIO	:= "Guinea Ecuatorial"
			Case cCod == "341" //Haitํ
				SYA->YA_SGLMEX 	:= "HT"
				SYA->YA_NASCIO	:= "Haitํ"
			Case cCod == "345" //Rep๚blica de Honduras
				SYA->YA_SGLMEX 	:= "HN"
				SYA->YA_NASCIO	:= "Rep๚blica de Honduras"
			Case cCod == "351" //Hong Kong
				SYA->YA_SGLMEX 	:= "HK"
				SYA->YA_NASCIO	:= "Hong Kong"
			Case cCod == "355" //Hungrํa
				SYA->YA_SGLMEX 	:= "HU"
				SYA->YA_NASCIO	:= "Hungrํa"
			Case cCod == "357" .Or. cCod == "358" //Yemen Democrแtica
				SYA->YA_SGLMEX 	:= "YD"
				SYA->YA_NASCIO	:= "Yemen Democrแtica"
			Case cCod == "357" //Madeira
				SYA->YA_SGLMEX 	:= "MD"
				SYA->YA_NASCIO	:= "Madeira"
			Case cCod == "361" //India
				SYA->YA_SGLMEX 	:= "IN"
				SYA->YA_NASCIO	:= "India"
			Case cCod == "365" //Indonesia
				SYA->YA_SGLMEX 	:= "ID"
				SYA->YA_NASCIO	:= "Indonesia"
			Case cCod == "372" //Irแn
				SYA->YA_SGLMEX 	:= "IR"
				SYA->YA_NASCIO	:= "Irแn"
			Case cCod == "369" //Iraq
				SYA->YA_SGLMEX 	:= "IQ"
				SYA->YA_NASCIO	:= "Iraq"
			Case cCod == "375" //Irlanda
				SYA->YA_SGLMEX 	:= "IE"
				SYA->YA_NASCIO	:= "Irlanda"
			Case cCod == "379" //Islandia
				SYA->YA_SGLMEX 	:= "IS"
				SYA->YA_NASCIO	:= "Islandia"
			Case cCod == "383" //Israel
				SYA->YA_SGLMEX 	:= "IL"
				SYA->YA_NASCIO	:= "Israel"
			Case cCod == "386" //Italia
				SYA->YA_SGLMEX 	:= "IT"
				SYA->YA_NASCIO	:= "Italia"
			Case cCod == "388" .Or. cCod == "449" //Paํses de la Ex - Yugoslavia
				SYA->YA_SGLMEX 	:= "YU"
				SYA->YA_NASCIO	:= "Paํses de la Ex - Yugoslavia"
			Case cCod == "391" //Jamaica
				SYA->YA_SGLMEX 	:= "JM"
				SYA->YA_NASCIO	:= "Jamaica"
			Case cCod == "399" //Jap๓n
				SYA->YA_SGLMEX 	:= "JP"
				SYA->YA_NASCIO	:= "Jap๓n"
			Case cCod == "150" //Islas de Jersey (Islas del Canal)
				SYA->YA_SGLMEX 	:= "GZ"
				SYA->YA_NASCIO	:= "Islas de Jersey (Islas del Canal)"
			Case cCod == "403" //Reino Hachemita de Jordania
				SYA->YA_SGLMEX 	:= "JO"
				SYA->YA_NASCIO	:= "Reino Hachemita de Jordania"
			Case cCod == "411" //Kiribati
				SYA->YA_SGLMEX 	:= "KI"
				SYA->YA_NASCIO	:= "Kiribati"
			Case cCod == "420" //Rep๚blica Democrแtica de Laos
				SYA->YA_SGLMEX 	:= "LA"
				SYA->YA_NASCIO	:= "Rep๚blica Democrแtica de Laos"
			Case cCod == "426" //Lesotho
				SYA->YA_SGLMEX 	:= "LS"
				SYA->YA_NASCIO	:= "Lesotho"
			Case cCod == "431" //Lํbano
				SYA->YA_SGLMEX 	:= "LB"
				SYA->YA_NASCIO	:= "Lํbano"
			Case cCod == "434" //Rep๚blica de Liberia
				SYA->YA_SGLMEX 	:= "LR"
				SYA->YA_NASCIO	:= "Rep๚blica de Liberia"
			Case cCod == "438" //Libia
				SYA->YA_SGLMEX 	:= "LY"
				SYA->YA_NASCIO	:= "Libia"
			Case cCod == "440" //Principado de Liechtenstein
				SYA->YA_SGLMEX 	:= "LI"
				SYA->YA_NASCIO	:= "Principado de Liechtenstein"
			Case cCod == "445" //Gran Ducado de Luxemburgo
				SYA->YA_SGLMEX 	:= "LU"
				SYA->YA_NASCIO	:= "Gran Ducado de Luxemburgo"
			Case cCod == "447" //Macao
				SYA->YA_SGLMEX 	:= "MO"
				SYA->YA_NASCIO	:= "Macao"
			Case cCod == "450" //Madagascar
				SYA->YA_SGLMEX 	:= "MG"
				SYA->YA_NASCIO	:= "Madagascar"
			Case cCod == "455" //Malasia 
				SYA->YA_SGLMEX 	:= "MY"
				SYA->YA_NASCIO	:= "Malasia"
			Case cCod == "458" //Malawi
				SYA->YA_SGLMEX 	:= "MW"
				SYA->YA_NASCIO	:= "Malawi"
			Case cCod == "461" //Rep๚blica de Maldivas
				SYA->YA_SGLMEX 	:= "MV"
				SYA->YA_NASCIO	:= "Rep๚blica de Maldivas"
			Case cCod == "464" //Malํ
				SYA->YA_SGLMEX 	:= "ML"
				SYA->YA_NASCIO	:= "Malํ"
			Case cCod == "467" //Malta
				SYA->YA_SGLMEX 	:= "MT"
				SYA->YA_NASCIO	:= "Malta"
			Case cCod == "472" //Islas Marianas del Noreste
				SYA->YA_SGLMEX 	:= "MP"
				SYA->YA_NASCIO	:= "Islas Marianas del Noreste"
			Case cCod == "474" //Marruecos
				SYA->YA_SGLMEX 	:= "MA"
				SYA->YA_NASCIO	:= "Marruecos"
			Case cCod == "476" //Rep๚blica de las Islas Marshall
				SYA->YA_SGLMEX 	:= "MH"
				SYA->YA_NASCIO	:= "Rep๚blica de las Islas Marshall"
			Case cCod == "477" //Martinica
				SYA->YA_SGLMEX 	:= "MQ"
				SYA->YA_NASCIO	:= "Martinica"
			Case cCod == "485" //Rep๚blica de Mauricio
				SYA->YA_SGLMEX 	:= "MU"
				SYA->YA_NASCIO	:= "Rep๚blica de Mauricio"
			Case cCod == "488" //Mauritania
				SYA->YA_SGLMEX 	:= "MR"
				SYA->YA_NASCIO	:= "Mauritania"
			Case cCod == "499" //Micronesia
				SYA->YA_SGLMEX 	:= "FM"
				SYA->YA_NASCIO	:= "Micronesia"
			Case cCod == "505" //Mozambique
				SYA->YA_SGLMEX 	:= "MZ"
				SYA->YA_NASCIO	:= "Mozambique"
			Case cCod == "497" //Mongolia
				SYA->YA_SGLMEX 	:= "MN"
				SYA->YA_NASCIO	:= "Mongolia"
			Case cCod == "501" //Monserrat
				SYA->YA_SGLMEX 	:= "MS"
				SYA->YA_NASCIO	:= "Monserrat"
			Case cCod == "507" //Rep๚blica de Namibia
				SYA->YA_SGLMEX 	:= "NA"
				SYA->YA_NASCIO	:= "Rep๚blica de Namibia"
			Case cCod == "508" //Rep๚blica de Nauru
				SYA->YA_SGLMEX 	:= "NR"
				SYA->YA_NASCIO	:= "Rep๚blica de Nauru"
			Case cCod == "517" //Nepal
				SYA->YA_SGLMEX 	:= "NP"
				SYA->YA_NASCIO	:= "Nepal"
			Case cCod == "521" //Nicaragua
				SYA->YA_SGLMEX 	:= "NI"
				SYA->YA_NASCIO	:= "Nicaragua"
			Case cCod == "525" //Nํger
				SYA->YA_SGLMEX 	:= "NE"
				SYA->YA_NASCIO	:= "Nํger"
			Case cCod == "528" //Nigeria
				SYA->YA_SGLMEX 	:= "NG"
				SYA->YA_NASCIO	:= "Nigeria"
			Case cCod == "531" //Niue
				SYA->YA_SGLMEX 	:= "NU"
				SYA->YA_NASCIO	:= "Niue"
			Case cCod == "535" //Isla de Norfolk
				SYA->YA_SGLMEX 	:= "NF"
				SYA->YA_NASCIO	:= "Isla de Norfolk"
			Case cCod == "538" //Noruega
				SYA->YA_SGLMEX 	:= "NO"
				SYA->YA_NASCIO	:= "Noruega"
			Case cCod == "542" //Nueva Caledonia
				SYA->YA_SGLMEX 	:= "NC"
				SYA->YA_NASCIO	:= "Nueva Caledonia"
			Case cCod == "548" //Nueva Zelandia
				SYA->YA_SGLMEX 	:= "NZ"
				SYA->YA_NASCIO	:= "Nueva Zelandia"
			Case cCod == "556" //Sultanํa de Omแn
				SYA->YA_SGLMEX 	:= "OM"
				SYA->YA_NASCIO	:= "Sultanํa de Omแn"
			Case cCod == "566" //Islas Pacํfico
				SYA->YA_SGLMEX 	:= "IP"
				SYA->YA_NASCIO	:= "Islas Pacํfico"
			Case cCod == "573" //Holanda
				SYA->YA_SGLMEX 	:= "NL"
				SYA->YA_NASCIO	:= "Holanda"
			Case cCod == "575" //Palau
				SYA->YA_SGLMEX 	:= "PW"
				SYA->YA_NASCIO	:= "Palau"
			Case cCod == "580" .Or. cCod == "895" //Rep๚blica de Panamแ
				SYA->YA_SGLMEX 	:= "PA"
				SYA->YA_NASCIO	:= "Rep๚blica de Panamแ"
			Case cCod == "583" .Or. cCod == "545" //Pap๚a Nueva Guinea
				SYA->YA_SGLMEX 	:= "PG"
				SYA->YA_NASCIO	:= "Pap๚a Nueva Guinea"
			Case cCod == "576"  //Pakistแn
				SYA->YA_SGLMEX 	:= "PK"
				SYA->YA_NASCIO	:= "Pakistแn"
			Case cCod == "586"  //Paraguay
				SYA->YA_SGLMEX 	:= "PY"
				SYA->YA_NASCIO	:= "Paraguay"
			Case cCod == "589"  //Per๚
				SYA->YA_SGLMEX 	:= "PE"
				SYA->YA_NASCIO	:= "Per๚"
			Case cCod == "593"  //Pitcairn 
				SYA->YA_SGLMEX 	:= "PN"
				SYA->YA_NASCIO	:= "Pitcairn"
			Case cCod == "599"  //Polinesia Francesa	 
				SYA->YA_SGLMEX 	:= "PF"
				SYA->YA_NASCIO	:= "Polinesia Francesa"
			Case cCod == "603"  //Polonia
				SYA->YA_SGLMEX 	:= "PL"
				SYA->YA_NASCIO	:= "Polonia"
			Case cCod == "611"  //Estado Libre Asociado de Puerto Rico
				SYA->YA_SGLMEX 	:= "PR"
				SYA->YA_NASCIO	:= "Estado Libre Asociado de Puerto Rico"
			Case cCod == "607"  //Portugal
				SYA->YA_SGLMEX 	:= "PT"
				SYA->YA_NASCIO	:= "Portugal"
			Case cCod == "495"  //Principado de M๓naco
				SYA->YA_SGLMEX 	:= "MC"
				SYA->YA_NASCIO	:= "Principado de M๓naco"
			Case cCod == "623"  //Kenia
				SYA->YA_SGLMEX 	:= "KE"
				SYA->YA_NASCIO	:= "Kenia"
			Case cCod == "628"  //  REINO UNIDO                             
			    SYA->YA_SGLMEX := "GB"
				SYA->YA_NASCIO := " Gran Breta๑a (Reino Unido)"	
			Case cCod == "640"  // REPUBLICA CENTRO-AFRICANA                              
			    SYA->YA_SGLMEX := "CF"
				SYA->YA_NASCIO := "Rep๚blica Centro Africana"		 		
			Case cCod == "647"  // REPUBLICA DOMINICANA                                              
			    SYA->YA_SGLMEX := "DM"
				SYA->YA_NASCIO := "Rep๚blica Dominicana"		 	
			Case cCod == "660"  // Reuni๓n
			    SYA->YA_SGLMEX := "RE"
				SYA->YA_NASCIO := "Reuni๓n"		 	
			Case cCod == "670"  //  ROMENIA                             
			    SYA->YA_SGLMEX := "RO"
				SYA->YA_NASCIO := "Rumania"	
			Case cCod == "675"  // RUANDA                                   
			    SYA->YA_SGLMEX := "RW"
				SYA->YA_NASCIO := " Rhuanda"
			Case cCod == "685"  //  SAARA OCIDENTAL                                       
			    SYA->YA_SGLMEX := "EH"
				SYA->YA_NASCIO := " Sahara del Oeste"
			Case cCod == "678"  // SAINT KITTS E NEVIS                                    
			    SYA->YA_SGLMEX := "KN"
				SYA->YA_NASCIO := "San Kitts"
			Case cCod == "677" // SALOMAO, ILHAS                                         
			    SYA->YA_SGLMEX := "SB"
				SYA->YA_NASCIO := "Islas Salom๓n"
			Case cCod == "690"  //  Estado Independiente de Samoa Occidental
			    SYA->YA_SGLMEX := "EO"
				SYA->YA_NASCIO := "Estado Independiente de Samoa Occidental"
			Case cCod == "691"  //  SAMOA AMERICANA                                       
			    SYA->YA_SGLMEX := "AS"
				SYA->YA_NASCIO := "Samoa Americana"
			Case cCod == "697"  //  Serenํsima Rep๚blica de San Marino
			    SYA->YA_SGLMEX := "SM"
				SYA->YA_NASCIO := "Serenํsima Rep๚blica de San Marino"
			Case cCod == "710"  // SANTA HELENA                              
			    SYA->YA_SGLMEX := "SH"
				SYA->YA_NASCIO := "Santa Elena"
			Case cCod == "715"  //  SANTA LUCIA                               
			    SYA->YA_SGLMEX := "LC"
				SYA->YA_NASCIO := "Santa Lucํa"	
			Case cCod == "700"  // SAO PEDRO E MIQUELON                                   
			    SYA->YA_SGLMEX := "PM"
				SYA->YA_NASCIO := "Isla de San Pedro y Miguel๓n"
			Case cCod == "720"  // SAO TOME E PRINCIPE, ILHA                              
			    SYA->YA_SGLMEX := "ST"
				SYA->YA_NASCIO := "Sao Tome and Prํncipe"	
			Case cCod == "705"  // SAO VICENTE E GRANADINAS                               
			    SYA->YA_SGLMEX := "VC"
				SYA->YA_NASCIO := " San Vicente y Las Granadinas"			
			Case cCod == "728"  // SENEGAL                              
			    SYA->YA_SGLMEX := "SN"
				SYA->YA_NASCIO := "Senegal"
			Case cCod == "735"  //  SERRA LEOA                             
			    SYA->YA_SGLMEX := "SL"
				SYA->YA_NASCIO := "Sierra Leona"
			Case cCod == "731"  // SEYCHELLES                                             
			    SYA->YA_SGLMEX := "SC"
				SYA->YA_NASCIO := "Seychelles Islas"
			Case cCod == "744"  //  SIRIA, REPUBLICA ARABE DA                               
			    SYA->YA_SGLMEX := "SY"
				SYA->YA_NASCIO := "Siria"	
			Case cCod == "748"  // SOMALIA                              
			    SYA->YA_SGLMEX := "SO"
				SYA->YA_NASCIO := "Somalia" 
			Case cCod == "750" // SRI LANKA                               
			    SYA->YA_SGLMEX := "LK"
				SYA->YA_NASCIO := "Rep๚blica Socialista Democrแtica de Sri Lanka" 
			Case cCod == "754"   // SUAZILANDIA                              
			    SYA->YA_SGLMEX := "SZ"
				SYA->YA_NASCIO := "Reino de Swazilandia" 
			Case cCod == "759" // SUDAO                              
			    SYA->YA_SGLMEX := "SD"
				SYA->YA_NASCIO := "Sudแn"
			Case cCod == "764"  // SUECIA                              
			    SYA->YA_SGLMEX := "SE"
				SYA->YA_NASCIO := "Suecia"
			Case cCod == "767"  //  SUICA                               
			    SYA->YA_SGLMEX := "CH"
				SYA->YA_NASCIO := "Suiza"						
			Case cCod == "770"  // SURINAME                              
			    SYA->YA_SGLMEX := "SR"
				SYA->YA_NASCIO := "Surinam"						
			Case cCod == "776"  // TAILANDIA                              
			    SYA->YA_SGLMEX := "TH"
				SYA->YA_NASCIO := "Thailandia"						
			Case cCod == "780"  // TANZANIA, REP.UNIDA DA                                 
			    SYA->YA_SGLMEX := "TZ"
				SYA->YA_NASCIO := "Tanzania"						
			Case cCod == "782"  // TERRITORIO BRIT.OC.INDICO                               
			    SYA->YA_SGLMEX := "IO"
				SYA->YA_NASCIO := "Territorio Britแnico en el Oc้ano Indico"						
			Case cCod == "795" // TIMOR LESTE                              
			    SYA->YA_SGLMEX := "TP"
				SYA->YA_NASCIO := "Timor Este"						
			Case cCod == "800" // TOGO                              
			    SYA->YA_SGLMEX := "TG"
				SYA->YA_NASCIO := "Togo"
			Case cCod == "810"   // TONGA                                         
			    SYA->YA_SGLMEX := "TO"
				SYA->YA_NASCIO := "Reino de Tonga"
			Case cCod == "805"   //Tokelau
			    SYA->YA_SGLMEX := "TK"
				SYA->YA_NASCIO := "Tokelau"
			Case cCod == "815"  // TRINIDAD E TOBAGO                                     
			    SYA->YA_SGLMEX := "TT"
				SYA->YA_NASCIO := "Rep๚blica de Trinidad y Tobago"
			Case cCod == "823"   // TURCAS E CAICOS,ILHAS                                  
			    SYA->YA_SGLMEX := "TC"
				SYA->YA_NASCIO := "Islas Turcas y Caicos"
			Case cCod == "827"   // TURQUIA                              
			    SYA->YA_SGLMEX := "TU"
				SYA->YA_NASCIO := "Turquํa"
			Case cCod == "828" // TUVALU                              
			    SYA->YA_SGLMEX := "TV"
				SYA->YA_NASCIO := "Tuvalu"
			Case cCod == "831"  // UCRANIA                              
			    SYA->YA_SGLMEX := "UA"
				SYA->YA_NASCIO := "Ucrania"			
			Case cCod == "833"  // UGANDA                              
			    SYA->YA_SGLMEX := "UG"
				SYA->YA_NASCIO := "Uganda"
			Case cCod == "840" .Or. cCod == "676" // URSS / RUSSIA                              
			    SYA->YA_SGLMEX := "SU"
				SYA->YA_NASCIO := "Paํses de la Ex -U.R.S.S., excepto Ucrania y Bielorusia"
			Case cCod == "845"  // URUGUAI
			    SYA->YA_SGLMEX := "UY"
				SYA->YA_NASCIO := "Rep๚blica Oriental del Uruguay"
			Case cCod == "551"  // Rep๚blica de Vanuatu
			    SYA->YA_SGLMEX := "VU"
				SYA->YA_NASCIO := "Rep๚blica de Vanuatu"
			Case cCod == "848"  // El Vaticano
			    SYA->YA_SGLMEX := "VA"
				SYA->YA_NASCIO := "El Vaticano"
			Case cCod == "850"  // VENEZUELA                              
			    SYA->YA_SGLMEX := "VE"
				SYA->YA_NASCIO := "Venezuela"
			Case cCod == "858"  // VIETNA
			    SYA->YA_SGLMEX := "VN"
				SYA->YA_NASCIO := "Vietnam"
			Case cCod == "863" // VIRGENS,ILHAS (BRITANICAS)                               
			    SYA->YA_SGLMEX := "VG"
				SYA->YA_NASCIO := "Islas Vํrgenes Britแnicas" 
			Case cCod == "866"  // VIRGENS,ILHAS (E.U.A.)                                  
			    SYA->YA_SGLMEX := "VI"
				SYA->YA_NASCIO := "Islas Vํrgenes de Estados Unidos de Am้rica" 
			Case cCod == "875"  // WALLIS E FUTUNA, ILHAS                                
			    SYA->YA_SGLMEX := "WF"
				SYA->YA_NASCIO := "Islas Wallis y Funtuna" 
			Case cCod == "890" // ZAMBIA                               
			    SYA->YA_SGLMEX := "ZM" 
				SYA->YA_NASCIO := "Zambia" 
			Case cCod == "665" // ZIMBABUE                 
				SYA->YA_SGLMEX := "ZW" 
				SYA->YA_NASCIO := "Zimbawe"  
			Case cCod == "756" // Sudแfrica
				SYA->YA_SGLMEX := "ZA" 
				SYA->YA_NASCIO := "Sudแfrica"  
			Case cCod == "259" // Islas Faroe
				SYA->YA_SGLMEX := "FO" 
				SYA->YA_NASCIO := "Islas Faroe"  
			Case cCod == "423" // Labuแn
				SYA->YA_SGLMEX := "LN" 
				SYA->YA_NASCIO := "Labuแn"  
			Case cCod == "359" // Isla del Hombre
				SYA->YA_SGLMEX := "IH" 
				SYA->YA_NASCIO := "Isla del Hombre"  
			Case cCod == "741" // Singapur
				SYA->YA_SGLMEX := "SG" 
				SYA->YA_NASCIO := "Singapur"  
			Case cCod == "154" // Estado de Quatar
				SYA->YA_SGLMEX := "QA" 
				SYA->YA_NASCIO := "Estado de Quatar"  
		EndCase

		MsUnLock()		
		SYA->(DbSkip())		
	EndDo
		       		
EndIf
                                                                        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a tabela temporaria - Informacoes para ini        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aEstru, {"CODIGO"		,"C",06,0})		//Cod proveedor
Aadd(aEstru, {"LOJA"  		,"C",02,0})		//Tienda proveedor
Aadd(aEstru, {"NOME" 		,"C",43,0})		//Nombre
Aadd(aEstru, {"PAIS"		,"C",02,0})		//Sigla del pais
Aadd(aEstru, {"NACIONAL"	,"C",40,0})		//Nacionalidad
Aadd(aEstru, {"RFC" 		,"C",14,0})		//RFC
Aadd(aEstru, {"IDFISCAL"	,"C",20,0})		//IDFiscal
Aadd(aEstru, {"TIPO3" 		,"C",02,0})		//Tipo de tercero
Aadd(aEstru, {"TIPOOP" 		,"C",02,0})		//Tipo de operacion
Aadd(aEstru, {"BSIVA0" 		,"N",15,0})    	//Base Aliquota Zero
Aadd(aEstru, {"BSIVA15" 	,"N",15,0})   	//Base Aliquota 15 
Aadd(aEstru, {"BSIVA16" 	,"N",15,0})   	//Base Aliquota 16  
Aadd(aEstru, {"BSIVA10" 	,"N",15,0})   	//Base Aliquota 10
Aadd(aEstru, {"BSIVA11" 	,"N",15,0})   	//Base Aliquota 11
Aadd(aEstru, {"BSIVA15I"	,"N",15,0})   	//Base Aliquota 15 importacion
Aadd(aEstru, {"BSIVA10I"	,"N",15,0})   	//Base Aliquota 10 importacion
Aadd(aEstru, {"BSIVAIE" 	,"N",15,0})    	//Base Exentos importacion
Aadd(aEstru, {"BSIVAE" 		,"N",15,0})    	//Base Exentos 
Aadd(aEstru, {"IVARET" 		,"N",15,0})   	//Iva retenido
Aadd(aEstru, {"IVADEV" 		,"N",15,0})    	//Iva Devoluciones (titulos tipo NCP - notas de credito proveedor)
Aadd(aEstru, {"BSIVAIM"		,"N",15,0})		//Base Importacion (todas as aliquotas)
Aadd(aEstru, {"BSIVA"		,"N",15,0})		//Base IVA (todas as aliquotas)
Aadd(aEstru, {"IVAIMP"		,"N",15,0})		//Iva importaciones
Aadd(aEstru, {"IVATRAS"		,"N",15,0})    	//Iva Trasladado
Aadd(aEstru, {"DTPAGO"		,"D",8,0})    	//Iva Trasladado
Aadd(aEstru, {"EXENTO"		,"C",01,0})    	//Exento?

aOrder := {"TIPO3","TIPOOP","RFC","IDFISCAL"}//JGR
oTmpDiot := FWTemporaryTable():New("DIO") //JGR
oTmpDiot:SetFields( aEstru )
oTmpDiot:AddIndex("I01", aOrder)
oTmpDiot:Create()

AADD(aTrb,"DIO")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a tabela temporaria - Detalhes da DIOT para res.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aEstruD, {"DATANF"		,"D",08,0})
Aadd(aEstruD, {"TIPO3"		,"C",02,0})
Aadd(aEstruD, {"TIPOOP"		,"C",02,0})
Aadd(aEstruD, {"CODIGO"		,"C",06,0})
Aadd(aEstruD, {"LOJA"		,"C",02,0})
Aadd(aEstruD, {"NOME"		,"C",43,0})
Aadd(aEstruD, {"RFC"		,"C",40,0})
Aadd(aEstruD, {"TIPODOC"	,"C",TamSX3("F1_ESPECIE")[01],0})
Aadd(aEstruD, {"NFISCAL"	,"C",TamSX3("F1_DOC")[01],0}) //Aadd(aEstruD, {"NFISCAL"	,"C",20,0}) //Aadd(aEstruD, {"NFISCAL"	,"C",TamSX3("F1_DOC")[01],0})
Aadd(aEstruD, {"SERIE"		,"C",TamSX3("F1_SERIE")[01],0})
Aadd(aEstruD, {"BSIVA15" 	,"N",15,0})  
Aadd(aEstruD, {"BSIVA16" 	,"N",15,0}) 	
Aadd(aEstruD, {"BSIVA10"	,"N",15,0})   
Aadd(aEstruD, {"BSIVA11"	,"N",15,0})   
Aadd(aEstruD, {"BSIVA15I"	,"N",15,0})   
Aadd(aEstruD, {"BSIVA10I"	,"N",15,0})   
Aadd(aEstruD, {"BSIVAIE"	,"N",15,0})   
Aadd(aEstruD, {"BSIVA0"		,"N",15,0})   
Aadd(aEstruD, {"BSIVAE"		,"N",15,0})   
Aadd(aEstruD, {"IVARET"		,"N",15,0})   
Aadd(aEstruD, {"IVADEV"		,"N",15,0})                     
Aadd(aEstruD, {"DTPAGO"		,"D",08,0})    	//Data de Pagto
Aadd(aEstruD, {"EXENTO"		,"C",01,0})    	//Exento?

aOrder := {"TIPO3","TIPOOP","CODIGO","LOJA","RFC","NFISCAL","SERIE"}//JGR
oTmpDet := FWTemporaryTable():New("DIT") //JGR
oTmpDet:SetFields( aEstruD )
oTmpDet:AddIndex("I01", aOrder)
oTmpDet:Create()

AADD(aTrb,"DIT")


//Copiar arreglo con las filiales
aCpyFilsC := aClone(aFilsCalc)

//Validar si la generaci?n del DIOT es consolidada
If  cConsol== "1" .And.  mv_par06 == 1    //Significa que el DIOT sera consolidado y que hubo seleccion de Sucursales
    //Cambiar logico para que NO continue procesando filiales    
	For nProcFil:=1 to len(aFilsCalc) 
		aFilsCalc[nProcFil,1]:=.F. 
	Next nProcFil
Else  
	cConsol:= "0" 
	//_aTotal[011] := .F.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca las informaciones sobre Ordens de pago / titulos ณ  
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aDetPag := RETPGTOS(cForIni, cLojaIni, cForFin, cLojaFin, dDtInicial, dDtFinal, cFiliDe, cFiliAte,"DIOTFILT",cConsol)
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณEstrutura do retorno do array aDetPag        ณ
ณ1 - Fornecedor								  ณ
ณ2 - Loja									  ณ
ณ3 - RFC									  ณ
ณ4 - CURP									  ณ
ณ5 - Notas									  ณ
ณ	5.01 - nota								  ณ
ณ	5.02 - Serie							  ณ
ณ	5.03 - valbrut (moeda 1)				  ณ
ณ	5.04 - valmerc (moeda 1)				  ณ
ณ	5.05 - moeda							  ณ
ณ	5.06 - taxa moeda						  ณ
ณ	5.07 - tipo pagamento (SF4->F4_CVEPAGO)	  ณ
ณ	5.08 - emissao							  ณ
ณ	5.09 - especie							  ณ
ณ	5.10 - valor pago (moeda 1)				  ณ
ณ	5.11 - compensacao(moeda 1)				  ณ
ณ	5.12 - impostos							  ณ
ณ		5.12.1 - codigo do imposto			  ณ
ณ		5.12.2 - aliquota					  ณ
ณ		5.12.3 - base (moeda 1)				  ณ
ณ		5.12.4 - valor (moeda 1)			  ณ
ณ	5.13 - Dta Pagto						  ณ
ณ6 - Filial								  	  ณ
ณ7 - NCP                                      ณ
ณ	7.1 - notas                               ณ  
ณ	7.2 - serie                               ณ
ณ	7.3 - emissao                             ณ
ณ	7.4 - iva                                 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

For nX := 1 to Len(aDetPag)

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+aDetPag[nX][1]+aDetPag[nX][2]))
	SYA->(DbSetOrder(1))
	SYA->(DbSeek(xFilial("SYA")+SA2->A2_PAIS))
   
	cNamePro  := SA2->A2_NOME   //LEMP(THAKVY)
	cCGC      := SA2->A2_CGC
	cIDFiscal := SA2->A2_IDFISCA  
	 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlimento a tabela DIO - para o arquivo magnetico       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI := 1 to Len(aDetPag[nX][5]) //Notas 
		cDataNF   := aDetPag[nX][5][nI][8] //Fecha NF
		cTIPODOC  := aDetPag[nX][5][nI][9] //Tipo doc -NF- 
		If  aDetPag[nX][8]=="15" ////LEMP(THAKVY):Es proveedor Global y se le debe dar otro tratamiento
			aDetPag[nX][1] := space(len(aDetPag[nX][1]))  //Cod. Proveedor
			aDetPag[nX][2] := space(len(aDetPag[nX][2]))  //Loja
			aDetPag[nX][5][nI][1] := space(len(aDetPag[nX][5][nI][1]))  //NF  
			aDetPag[nX][5][nI][2] := space(len(aDetPag[nX][5][nI][2]))  //Serie 
			cNamePro  := Iif(aDetPag[nX][9]=="03",cOper03,Iif(aDetPag[nX][9]=="06",cOper06,cOper85)) //Nombre del Proveedor    
			cCGC      := Space(len(SA2->A2_CGC))
			cIDFiscal := Space(len(SA2->A2_IDFISCA))   
			cDataNF   := ctod("//") 
			cTIPODOC  := Space(len(aDetPag[nX][5][nI][9]))
		Endif    
		cChave 		:= SA2->A2_TIPOTER+SA2->A2_TPOPER+cCGC+cIDFiscal 	//Tipo3 + TipoOper + RFC + IDFISCAL
		
		cChaveDet 	:= 	SA2->A2_TIPOTER+SA2->A2_TPOPER+aDetPag[nX][1]+aDetPag[nX][2]+;
						Padr(Iif(SA2->A2_TIPOTER=="04",cCGC,Iif(SA2->A2_TIPOTER=="15","", cIDFiscal)),40)+;
						aDetPag[nX][5][nI][1]+aDetPag[nX][5][nI][2] 	//Tipo3 + TipoOper + Fornecedor + Loja + RFC + NFiscal + Serie
						//LEMP(17/04/13):Validar proveedor global
		For nY := 1 to Len(aDetPag[nX][5][nI][12])

			If Subs(aDetPag[nX][5][nI][12][nY][1],1,2)=="IV"  
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAlimento a tabela DIO - para o arquivo magnetico       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("DIO")
				If !(DIO->(DbSeek(cChave)))
					nTotOper++	
					RecLock("DIO",.T.) 
					DIO->CODIGO		:= aDetPag[nX][1]
					DIO->LOJA		:= aDetPag[nX][2]
					DIO->NOME		:= cNamePro  //LEMP(THAKVY)
					DIO->PAIS		:= SYA->YA_SGLMEX   
					DIO->NACIONAL	:= SYA->YA_NASCIO
					DIO->RFC		:= cCGC    //LEMP(THAKVY)
					DIO->IDFISCAL	:= cIDFiscal
					DIO->TIPO3		:= SA2->A2_TIPOTER
					DIO->TIPOOP		:= SA2->A2_TPOPER    
				Else
					RecLock("DIO",.F.)	
				Endif

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAlimento a tabela DIT - para o relatorio detalhado     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู											
				dbSelectArea("DIT")
				If !(DIT->(DbSeek(cChaveDet)))
					RecLock("DIT",.T.) 
					DIT->DATANF		:= cDataNF
					DIT->TIPO3		:= SA2->A2_TIPOTER
					DIT->TIPOOP		:= SA2->A2_TPOPER
					DIT->CODIGO		:= aDetPag[nX][1]
					DIT->LOJA		:= aDetPag[nX][2]
					DIT->NOME		:= cNamePro  //LEMP(THAKVY)
					DIT->RFC		:= Iif(SA2->A2_TIPOTER$"04/15",cCGC,cIDFiscal)   //LEMP(THAKVY)
					DIT->TIPODOC 	:= cTIPODOC
					DIT->NFISCAL	:= aDetPag[nX][5][nI][1]					
					DIT->SERIE		:= aDetPag[nX][5][nI][2]			//Bruno Cremaschi - Projeto chave ๚nica.
					DIT->DTPAGO		:= aDetPag[nX][5][nI][13]
				Else
					RecLock("DIT",.F.)	
				Endif

				Do Case //Separo por aliquotas / importacion / exentos
					CASE aDetPag[nX][5][nI][12][nY][2] == 0  .And. aDetPag[nX][5][nI][12][nY][3] <> 0 //aliquota zerada mas base direferente de zero
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4]) 
						DIO->BSIVA0	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						DIT->BSIVA0	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[11]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)      
						//aTotaliz[15]	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)    //LEMP(08/07/11):No se debe considerar IVA es 0   											     										 				
					CASE aDetPag[nX][5][nI][12][nY][2] == 0  .And. aDetPag[nX][5][nI][12][nY][3] == 0 .And. SA2->A2_TIPOTER=="04"  	//aliquota zerada e base zerada - isento
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])                                       //so exentos 
						DIO->BSIVAE	  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)	  //LEMP(11/10/11):Como la base es 0, debe mostrar como base el total del documento	              				
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)        				
						DIT->BSIVAE	  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)		            				
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[12]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor) //LEMP(27/06/11): Como la base es 0, debe mostrar como total la base del documento (en la parte del resumen)      	 
						DIO->EXENTO		:=	"1"
						DIT->EXENTO		:=	"1"
					CASE aDetPag[nX][5][nI][12][nY][2] == 0  .And. aDetPag[nX][5][nI][12][nY][3] == 0 .And. !(SA2->A2_TIPOTER$"04/15") 	//aliquota zerada e base zerada - isento  //LEMP(17/04/13):Validar proveedor global
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])				                    	//exentos importacion 
						// aDetPag[nX][5][nI][12][nY][4]:= aDetPag[nX][5][nI][12][nY][4]*1000										// ARL (02/09/2011) !!!???
						DIO->BSIVAIE  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)	    //LEMP(11/10/11):Como la base es 0, debe mostrar como base el total del documento	              				
						DIT->BSIVAIE  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)		            				
						aTotaliz[10]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor) //(aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						//aTotaliz[16]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)													// ARL (07/09/2011) no acumula el exento
						DIO->EXENTO		:=	"1"
						DIT->EXENTO		:=	"1"
					CASE aDetPag[nX][5][nI][12][nY][2] == 10 .And. ( (aDetPag[nX][5][nI][8]<=Ctod('31/12/09')) ;       // IVA 10%   ( Nacional)
	   					.And. aDetPag[nX][5][nI][13]<=Ctod('10/01/10')) .And. SA2->A2_TIPOTER$"04/15"      //LEMP(17/04/13):Validar proveedor global
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA10	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIT->BSIVA10	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[04]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)  
						aTotaliz[15]	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       											     				
					CASE (aDetPag[nX][5][nI][12][nY][2] == 10 .or. aDetPag[nX][5][nI][12][nY][2] == 11  )  .And. ;      // IVA 10%   ( Nacional)
						( aDetPag[nX][5][nI][8]>=Ctod('01/01/10') .Or. (aDetPag[nX][5][nI][8]<=Ctod('31/12/09') ;
						.And. aDetPag[nX][5][nI][13]>=Ctod('11/01/10'))) .And. SA2->A2_TIPOTER$"04/15"   //Iva 10 ou 11%   ( Nacional) //LEMP(17/04/13):Validar proveedor global

						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA11	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIT->BSIVA11	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[18]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)                 
						//aTotaliz[15]	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       											     										
						aTotaliz[15]	+= ((aDetPag[nX][5][nI][12][nY][3]*nPropor)*0.11)
					CASE aDetPag[nX][5][nI][12][nY][2] == 15 .And. ;
						( (aDetPag[nX][5][nI][8]<=Ctod('31/12/09')) .And. aDetPag[nX][5][nI][13]<=Ctod('10/01/10')) .And. SA2->A2_TIPOTER=="04"   //Iva 15 ou 16%   ( Nacional)   //Iva 15    ( Nacional)
						
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA15	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIT->BSIVA15	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)  
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[02]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)  
						aTotaliz[15]	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       											     										     				
					CASE (aDetPag[nX][5][nI][12][nY][2] == 15  .or. aDetPag[nX][5][nI][12][nY][2] == 16  ) .And.;
						( aDetPag[nX][5][nI][8]>=Ctod('01/01/10') .Or. (aDetPag[nX][5][nI][8]<=Ctod('31/12/09') ;
						.And. aDetPag[nX][5][nI][13]>=Ctod('11/01/10'))) .And. SA2->A2_TIPOTER$"04/15"   //Iva 15 ou 16%   ( Nacional)   //LEMP(17/04/13):Validar proveedor global

						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA16	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVA	  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIT->BSIVA16	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)  
						DIO->IVATRAS  	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       										
						aTotaliz[17]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)  
//						aTotaliz[15]	+=  (aDetPag[nX][5][nI][12][nY][4]*nPropor)       
						aTotaliz[15]	+= ((aDetPag[nX][5][nI][12][nY][3]*nPropor)*0.16)											     										     				
					CASE (aDetPag[nX][5][nI][12][nY][2] == 10 .or. aDetPag[nX][5][nI][12][nY][2] == 11 ).And. !(SA2->A2_TIPOTER$"04/15") // IVA 10%  ( Estrangeiro)  //LEMP(17/04/13):Validar proveedor global
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA10I	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVAIM  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->IVAIMP  	  	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
						DIT->BSIVA10I	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						aTotaliz[08]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						aTotaliz[16]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
					CASE (aDetPag[nX][5][nI][12][nY][2] == 15 .Or. aDetPag[nX][5][nI][12][nY][2] == 16 ).And. !(SA2->A2_TIPOTER$"04/15") // IVA 15%  ( Estrangeiro)  //LEMP(17/04/13):Validar proveedor global
						nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])					
						DIO->BSIVA15I	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->BSIVAIM  	+=  (aDetPag[nX][5][nI][12][nY][3]*nPropor)
						DIO->IVAIMP    	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
						DIT->BSIVA15I	+=	(aDetPag[nX][5][nI][12][nY][3]*nPropor)
						aTotaliz[06]	+= 	(aDetPag[nX][5][nI][12][nY][3]*nPropor)       				
						aTotaliz[16]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
				EndCase  
				DIO->(MsUnLock())  	 
				DIT->(MsUnLock())  	 
							
			ElseIf Subs(aDetPag[nX][5][nI][12][nY][1],1,2)=="RI" .Or. aDetPag[nX][5][nI][12][nY][1] == "REF"

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAlimento a tabela DIO - para o arquivo magnetico       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("DIO")
				If !(DIO->(DbSeek(cChave)))
					nTotoper++
					RecLock("DIO",.T.) 
					DIO->CODIGO		:= aDetPag[nX][1]
					DIO->LOJA		:= aDetPag[nX][2]
					DIO->NOME		:= cNamePro   //LEMP(THAKVY)
					DIO->PAIS		:= SYA->YA_SGLMEX
					DIO->NACIONAL	:= SYA->YA_NASCIO
					DIO->RFC		:= cCGC
					DIO->IDFISCAL	:= cIDFiscal
					DIO->TIPO3		:= SA2->A2_TIPOTER
					DIO->TIPOOP		:= SA2->A2_TPOPER    
				Else
					RecLock("DIO",.F.)	
				Endif

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAlimento a tabela DIT - para o relatorio detalhado     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู											
				dbSelectArea("DIT")
				If !(DIT->(DbSeek(cChaveDet)))
					RecLock("DIT",.T.) 
					DIT->DATANF		:= cDataNF      //LEMP(THAKVY)
					DIT->TIPO3		:= SA2->A2_TIPOTER
					DIT->TIPOOP		:= SA2->A2_TPOPER
					DIT->CODIGO		:= aDetPag[nX][1]
					DIT->LOJA		:= aDetPag[nX][2]
					DIT->NOME		:= cNamePro
					DIT->RFC		:= Iif(SA2->A2_TIPOTER$"04/15",cCGC,cIDFiscal)  //LEMP(17/04/13):Validar proveedor global
					DIT->TIPODOC 	:= cTIPODOC
					DIT->NFISCAL	:= aDetPag[nX][5][nI][1]
					//Bruno Cremaschi - Projeto chave ๚nica.
					DIT->SERIE		:= aDetPag[nX][5][nI][2]
				Else
					RecLock("DIT",.F.)	
				Endif

				nPropor			:= 	(aDetPag[nX][5][nI][10]/aDetPag[nX][5][nI][4])
	        	DIO->IVARET		+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
	        	DIT->IVARET		+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
				aTotaliz[13]	+= 	(aDetPag[nX][5][nI][12][nY][4]*nPropor)       				
				DIT->DTPAGO		:= aDetPag[nX][5][nI][13]
				
				DIO->(MsUnLock())  	     
				DIT->(MsUnLock())  	 				   	
			EndIf		
		Next
    Next       	
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlimento a tabela DIO - para o arquivo magnetico       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI := 1 to Len(aDetPag[nX][7]) //NCP (No aplica globales)

		cChaveDet 	:= 	SA2->A2_TIPOTER+SA2->A2_TPOPER+aDetPag[nX][1]+aDetPag[nX][2]+;
						Padr(Iif(SA2->A2_TIPOTER$"04/15",SA2->A2_CGC,SA2->A2_IDFISCA),40)+;
						aDetPag[nX][7][nI][1]+aDetPag[nX][7][nI][2] 	//Tipo3 + TipoOper + Fornecedor + Loja + RFC + NFiscal + Serie
						//LEMP(17/04/13):Validar proveedor global
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAlimento a tabela DIO - para o arquivo magnetico       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("DIO")
		If !(DIO->(DbSeek(cChave)))
			nTotOper++	
			RecLock("DIO",.T.) 
			DIO->CODIGO		:= aDetPag[nX][1]
			DIO->LOJA		:= aDetPag[nX][2]
			DIO->NOME		:= SA2->A2_NOME
			DIO->PAIS		:= SYA->YA_SGLMEX
			DIO->NACIONAL	:= SYA->YA_NASCIO
			DIO->RFC		:= SA2->A2_CGC
			DIO->IDFISCAL	:= SA2->A2_IDFISCA
			DIO->TIPO3		:= SA2->A2_TIPOTER
			DIO->TIPOOP		:= SA2->A2_TPOPER    
		Else
			RecLock("DIO",.F.)	
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAlimento a tabela DIT - para o relatorio detalhado     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู											
		dbSelectArea("DIT")
		If !(DIT->(DbSeek(cChaveDet)))
			RecLock("DIT",.T.) 
			DIT->DATANF		:= aDetPag[nX][7][nI][3]
			DIT->TIPO3		:= SA2->A2_TIPOTER
			DIT->TIPOOP		:= SA2->A2_TPOPER
			DIT->CODIGO		:= aDetPag[nX][1]
			DIT->LOJA		:= aDetPag[nX][2]
			DIT->NOME		:= SA2->A2_NOME
			DIT->RFC		:= Iif(SA2->A2_TIPOTER$"04/15",SA2->A2_CGC,SA2->A2_IDFISCA) //LEMP(17/04/13):Validar proveedor global
			DIT->TIPODOC 	:= "NCP"
			DIT->NFISCAL	:= aDetPag[nX][7][nI][1]
			//Bruno Cremaschi - Projeto chave ๚nica.
			DIT->SERIE		:= aDetPag[nX][7][nI][2]
			DIT->DTPAGO		:= aDetPag[nX][7][nI][3] //LEMP(THAKVY)
		Else
			RecLock("DIT",.F.)	
		Endif
       	DIO->IVADEV		+= 	aDetPag[nX][7][nI][4]
        DIT->IVADEV		+= 	aDetPag[nX][7][nI][4]
		aTotaliz[14]	+= 	aDetPag[nX][7][nI][4]
		
		DIO->(MsUnLock())  	 
		DIT->(MsUnLock())  	
	Next  
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlimento o array aTotaliz para o resumo das informacoes  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aTotaliz[01] := nTotOper

// Filtra registros en cero
cFiltroDIO := "(Empty(EXENTO) .And. BSIVA0<>0) .Or. !Empty(EXENTO) .Or. BSIVA<>0 .Or. IVATRAS<>0 .Or. BSIVA10<>0 .Or. BSIVA11<>0 .Or. BSIVA15<>0 .Or. BSIVA16<>0 .Or. BSIVA10I<>0 .Or. BSIVA15I<>0 .Or. BSIVAIM<>0 .Or. IVAIMP<>0 .Or. IVARET<>0 .Or. IVADEV<>0"
bFiltroDIO := &( "{|| " + cFiltroDIO + " }" )
DIO->(DbSetFilter(bFiltroDIO,cFiltroDIO))
DIO->(DbGoTop())
// Volver a contar registros
nTotOper := 0
dbSelectArea("DIO")
Count to nTotOper
aTotaliz[01] := nTotOper
DIO->(DbGoTop())

cFiltroDIT := "(Empty(EXENTO) .And. BSIVA0<>0) .Or. !Empty(EXENTO) .Or. BSIVA10<>0 .Or. BSIVA11<>0 .Or. BSIVA15<>0 .Or. BSIVA16<>0 .Or. BSIVA10I<>0 .Or. BSIVA15I<>0 .Or. IVARET<>0 .Or. IVADEV<>0"
bFiltroDIT := &( "{|| " + cFiltroDIT + " }" )
DIT->(DbSetFilter(bFiltroDIT,cFiltroDIT))
DIT->(DbGoTop())

RestArea(aArea)

DIOTValMex(dDtInicial,dDtFinal,cConsol)
DIOTRESMEX(dDtInicial,dDtFinal,cConsol)

Return(aTrb)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTRESMEXบAutor  ณLuciana Pires       บFecha ณ 01/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del resumen de las informaciones de clientes y    บฑฑ
ฑฑบ          ณproveedores                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIOT - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DIOTRESMEX(dDtInicial,dDtFinal,cConsol)
Local aArea	:= {}
Local oReport

If MsgYesNo(STR0001,"DIOT")	//"ฟ Desea imprimir el resumen de las informaciones ?"
	aArea := GetArea()
	oReport := TReport():New("DIOTRES",STR0002,,{|oReport| DIOTResImp(oReport,dDtInicial,dDtFinal,cConsol)},STR0003) //"Resumen de Informaciones" # "Resumen de la Declaraci๓n informativa de operaciones con terceros"
		oReport:SetPortrait() 
		oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()	// ARL 12/04/2012 Con Print(.F.) sํ imprime en P8 y P10!
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTRESIMPบAutor  ณLuciana Pires       บFecha ณ 01/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del resumen de las informaciones de operaciones   บฑฑ
ฑฑบ          ณcon terceros                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIOT - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DIOTResImp(oReport,dDtInicial,dDtFinal,cConsol)
Local aRect	:= {}
Local oBrush
Local oFont

oReport:SetTitle(STR0003 +Iif(cConsol=="0",""," Consolidado")+  "  -  " + Dtoc(dDtInicial) + " - " + Dtoc(dDtFinal)) //"Resumen de la Declaraci๓n informativa de operaciones con terceros"
oDetalhe := TRSection():New(oReport,STR0004,)	//"Informaciones de operacion con terceros"
	TRCell():New(oDetalhe,"DIO_TXT",,"",,100,.F.)
	TRCell():New(oDetalhe,"DIO_VLR",,"",,20,.F.)

oFont := TFont():New(oReport:cFontBody,,,,.T.,,.T.,,.F.,,,,,,,)
oBrush  := TBrush():New(,RGB(0,0,0))
oReport:SetMeter(11)
oDetalhe:SetHeaderSection(.F.)
oDetalhe:Init()
oDetalhe:Cell("DIO_TXT"):Hide()
oDetalhe:Cell("DIO_VLR"):Hide()
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncRow()
oDetalhe:Cell("DIO_TXT"):Show()
oDetalhe:Cell("DIO_VLR"):Show()
/*ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณResumen de las informaciones           ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/
oReport:IncRow()
oReport:IncRow()
oReport:IncRow()
oReport:IncRow()
oReport:Say(oReport:Row(),oDetalhe:Cell("DIO_TXT"):ColPos(),STR0005,oFont,100) //"TOTALES DECLARACION INFORMATIVA DE OPERACIำN CON TERCEROS"
oReport:IncRow()
oReport:IncRow()
aRect := {oReport:Row(),oDetalhe:Cell("DIO_TXT"):ColPos(),oReport:Row()+2,oReport:PageWidth()-2}
oReport:FillRect(aRect,oBrush)
oReport:IncRow()
//1 - Total de operaciones que relaciona
oDetalhe:Cell("DIO_TXT"):SetValue(STR0006)	
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[01],"@E 9999999999999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//2 - Total de los actos o actividades pagados a la tasa del 15% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0007)	
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[02],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter() 

//2 - Total de los actos o actividades pagados a la tasa del 16% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0030)	
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[17],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()

//3 - Total de IVA pagado NO acreditable a la tasa del 15%
oDetalhe:Cell("DIO_TXT"):SetValue(STR0008)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[03],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//4 - Total de los actos o actividades pagados a la tasa del 10% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0009)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[04],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow() 

//18 - Total de los actos o actividades pagados a la tasa del 11% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0031)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[18],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()

//5 - Total de IVA pagado NO acreditable a la tasa del 10%
oDetalhe:Cell("DIO_TXT"):SetValue(STR0010)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[05],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//6 - Total de los actos o actividades pagados a la importaci๓n de bienes y servicios a la tasa del 15% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0011)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[06],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//7 - Total de IVA pagado NO acreditable por la importaci๓n de bienes y servicios a la tasa del 15%
oDetalhe:Cell("DIO_TXT"):SetValue(STR0012)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[07],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//8 - Total de los actos o actividades pagados a la importaci๓n de bienes y servicios a la tasa del 10% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0013)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[08],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
//9 - Total de IVA pagado NO acreditable por la importaci๓n de bienes y servicios a la tasa del 10%
oDetalhe:Cell("DIO_TXT"):SetValue(STR0014)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[09],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//10 - Total de los actos o actividades pagados a la importaci๓n de bienes y servicios exentos de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0015)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[10],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
//11 - Total de los actos o actividades pagados a la tasa del 0% de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0016)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[11],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//12 - Total de los actos o actividades pagados exentos de IVA
oDetalhe:Cell("DIO_TXT"):SetValue(STR0017)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[12],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//13 - Total de IVA retenido
oDetalhe:Cell("DIO_TXT"):SetValue(STR0018)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[13],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//14 - Total de IVA por devoluciones, descuentos uy bonificaciones sobre compras
oDetalhe:Cell("DIO_TXT"):SetValue(STR0019)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[14],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//15 - Total de IVA transalado (pagado) excepto importaciones de bienes y servicios
oDetalhe:Cell("DIO_TXT"):SetValue(STR0020)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[15],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//16 - Total de IVA pagado en las importaciones de bienes y servicios
oDetalhe:Cell("DIO_TXT"):SetValue(STR0021)
oDetalhe:Cell("DIO_VLR"):SetValue(Transform(aTotaliz[16],"@E 9,999,999,999,999"))
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncMeter()
//
oReport:IncMeter()
oDetalhe:Finish()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTVALMEXบAutor  ณLuciana Pires       บFecha ณ 01/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del report para validacion de la generacion del   บฑฑ
ฑฑบ          ณarchivo para DIOT                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIOT - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DIOTValMex(dDtInicial,dDtFinal,cConsol)
Local aArea := {}
Local oReport

If MsgYesNo(STR0022,"DIOT") //"ฟ Desea imprimir el reporte para validaci๓n de las informaciones ?"
	aArea := GetArea()
	oReport := TReport():New("DIOT",STR0023,,{|oReport| DIOTValImp(oReport,dDtInicial,dDtFinal,cConsol)},STR0024) //"Reporte de validaci๓n de las Informaciones" # "Reporte de validaci๓n de las Informaciones generadas"
		oReport:SetLandscape() 
		oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTVALIMPบAutor  ณLuciana Pires       บFecha ณ 01/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del report para validacion de la generacion del   บฑฑ
ฑฑบ          ณarchivo para DIOT                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIOT - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DIOTValImp(oReport,dDtInicial,dDtFinal,cConsol)
Local nLin		:= 0
Local nAltPag	:= 0
//Bruno Cremaschi - Projeto chave ๚nica.
local cSDoc		:= SerieNFID("SF1", 3, "F1_SERIE")

oReport:SetTitle( STR0025 +Iif(cConsol=="0",""," Consolidado")+ "  -  " + Dtoc(dDtInicial) + " - " + Dtoc(dDtFinal)) //"Reporte de las informaciones generadas para DIOT"
oDetalhe := TRSection():New(oReport,STR0004,)//"Informaciones de operaciones con terceros"
	TRCell():New(oDetalhe,"DATANF"	,,"F.Emis."					,,12,.F.)
	TRCell():New(oDetalhe,"TIPO3"	,,"Tp 3ro"		    		,,02,.F.)
	TRCell():New(oDetalhe,"TIPOOP"	,,"Tp.Op"			    	,,02,.F.)
	TRCell():New(oDetalhe,"CODIGO"	,,"Cod.Prov"				,,06,.F.)//"Cod. Prov."
	TRCell():New(oDetalhe,"NOME"	,,alltrim(STR0027)			,,20,.F.)//"Nombre"
	TRCell():New(oDetalhe,"RFC"		,,"RFC/ID"					,,14,.F.)
	TRCell():New(oDetalhe,"TIPODOC"	,,"Tp Doc"		    		,,TamSX3("F1_ESPECIE")[01],.F.)
	TRCell():New(oDetalhe,"NFISCAL"	,,"N.de Doc."       	    ,,28,.F.) //TRCell():New(oDetalhe,"NFISCAL"	,,"N.de Doc."       	    ,,20,.F.)
	//Bruno Cremaschi - Projeto chave ๚nica.
	TRCell():New(oDetalhe,"SERIE"	,,RetTitle("F1_SERIE")		,,TamSX3(cSDoc)[01],.F.)
	TRCell():New(oDetalhe,"BSIVA15"	,,"Bs.15%"					,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVA16"	,,"Bs.15/16%"				,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVA10"	,,"Bs.10%"					,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVA11"	,,"Bs.10/11%"				,"@E 999,999,999,999,999",15,.F.)	
	TRCell():New(oDetalhe,"BSIVA15I",,"Bs.15% Imp"				,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVA10I",,"Bs.10% Imp"				,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVAIE"	,,alltrim(STR0028)			,"@E 999,999,999,999,999",15,.F.) //"Base Exe Imp"
	TRCell():New(oDetalhe,"BSIVA0"	,,"Bs.0%"					,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"BSIVAE"	,,alltrim(STR0029)			,"@E 999,999,999,999,999",15,.F.)//"Base Exento"
	TRCell():New(oDetalhe,"IVARET"	,,"IVA Ret"					,"@E 999,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"IVADEV"	,,"IVA NCP"					,"@E 999,999,999,999,999",15,.F.)
//
nAltPag := oReport:PageHeight() - 2
nLin := 0
oReport:SetMeter(DIT->(RecCount()) + 1)
oDetalhe:Init()

//Informaciones Detalhadas da declaracion
DIT->(DbGoTop())
While !oReport:Cancel() .And. !DIT->(Eof())
	oDetalhe:Cell("DATANF"):SetValue(DIT->DATANF)
	oDetalhe:Cell("TIPO3"):SetValue(DIT->TIPO3)
	oDetalhe:Cell("TIPOOP"):SetValue(DIT->TIPOOP)
	oDetalhe:Cell("CODIGO"):SetValue(DIT->CODIGO)
	oDetalhe:Cell("NOME"):SetValue(DIT->NOME)
	oDetalhe:Cell("RFC"):SetValue(DIT->RFC)
	oDetalhe:Cell("TIPODOC"):SetValue(DIT->TIPODOC)
	oDetalhe:Cell("NFISCAL"):SetValue(DIT->NFISCAL)
	oDetalhe:Cell("SERIE"):SetValue(DIT->SERIE)
	oDetalhe:Cell("BSIVA15"):SetValue(DIT->BSIVA15)
	oDetalhe:Cell("BSIVA16"):SetValue(DIT->BSIVA16)	
	oDetalhe:Cell("BSIVA10"):SetValue(DIT->BSIVA10)
	oDetalhe:Cell("BSIVA11"):SetValue(DIT->BSIVA11)	
	oDetalhe:Cell("BSIVA15I"):SetValue(DIT->BSIVA15I)
	oDetalhe:Cell("BSIVA10I"):SetValue(DIT->BSIVA10I)
	oDetalhe:Cell("BSIVAIE"):SetValue(DIT->BSIVAIE)
	oDetalhe:Cell("BSIVA0"):SetValue(DIT->BSIVA0)
	oDetalhe:Cell("BSIVAE"):SetValue(DIT->BSIVAE)
	oDetalhe:Cell("IVARET"):SetValue(DIT->IVARET)
	oDetalhe:Cell("IVADEV"):SetValue(DIT->IVADEV)
	oDetalhe:PrintLine()
	nLin := oReport:Row()
	If nLin >= nAltPag
		oReport:EndPage()
		oDetalhe:Init()
		oDetalhe:cell("DIT_TIPO3"):Show()
	Endif
	DIT->(DbSkip())
	oReport:IncMeter()
Enddo
//
oReport:IncMeter()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIOTDel     บAutor  ณLuciana Pires       บ Data ณ 01.11.2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta os arquivos temporarios processados                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณDIOT                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function DIOTDel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		dbSelectArea(aDelArqs[ni])
			dbCloseArea()
	Next

	If oTmpDiot <> Nil   //JGR
		oTmpDiot:Delete()
		oTmpDiot:= Nil
	Endif

	If oTmpDet <> Nil   //JGR
		oTmpDet:Delete()
		oTmpDet:= Nil
		Endif	


	RestArea(aAreaDel)
Return