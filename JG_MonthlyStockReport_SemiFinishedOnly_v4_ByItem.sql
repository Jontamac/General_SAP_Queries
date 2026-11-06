CREATE VIEW "CONTAMAC_LIVE"."JG_MonthlyStockReport_SemiFinishedOnly_v4_ByItem" ( "Month",
	 "ItemCode",
	 "ItemName",
	 "Total Stock Value",
	 "Total Stock Qty" ) AS WITH "MONTHS" ("Month",
	 "Cutoff") AS (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((SELECT
	 '2023-01' AS "Month",
	 TO_DATE('20230131',
	 'YYYYMMDD') AS "Cutoff" 
																																																																																																													FROM DUMMY) 
																																																																																																												UNION ALL (SELECT
	 '2023-02',
	 TO_DATE('20230228',
	 'YYYYMMDD') 
																																																																																																													FROM DUMMY)) 
																																																																																																											UNION ALL (SELECT
	 '2023-03',
	 TO_DATE('20230331',
	 'YYYYMMDD') 
																																																																																																												FROM DUMMY)) 
																																																																																																										UNION ALL (SELECT
	 '2023-04',
	 TO_DATE('20230430',
	 'YYYYMMDD') 
																																																																																																											FROM DUMMY)) 
																																																																																																									UNION ALL (SELECT
	 '2023-05',
	 TO_DATE('20230531',
	 'YYYYMMDD') 
																																																																																																										FROM DUMMY)) 
																																																																																																								UNION ALL (SELECT
	 '2023-06',
	 TO_DATE('20230630',
	 'YYYYMMDD') 
																																																																																																									FROM DUMMY)) 
																																																																																																							UNION ALL (SELECT
	 '2023-07',
	 TO_DATE('20230731',
	 'YYYYMMDD') 
																																																																																																								FROM DUMMY)) 
																																																																																																						UNION ALL (SELECT
	 '2023-08',
	 TO_DATE('20230831',
	 'YYYYMMDD') 
																																																																																																							FROM DUMMY)) 
																																																																																																					UNION ALL (SELECT
	 '2023-09',
	 TO_DATE('20230930',
	 'YYYYMMDD') 
																																																																																																						FROM DUMMY)) 
																																																																																																				UNION ALL (SELECT
	 '2023-10',
	 TO_DATE('20231031',
	 'YYYYMMDD') 
																																																																																																					FROM DUMMY)) 
																																																																																																			UNION ALL (SELECT
	 '2023-11',
	 TO_DATE('20231130',
	 'YYYYMMDD') 
																																																																																																				FROM DUMMY)) 
																																																																																																		UNION ALL (SELECT
	 '2023-12',
	 TO_DATE('20231231',
	 'YYYYMMDD') 
																																																																																																			FROM DUMMY)) 
																																																																																																	UNION ALL (SELECT
	 '2024-01',
	 TO_DATE('20240131',
	 'YYYYMMDD') 
																																																																																																		FROM DUMMY)) 
																																																																																																UNION ALL (SELECT
	 '2024-02',
	 TO_DATE('20240229',
	 'YYYYMMDD') 
																																																																																																	FROM DUMMY)) 
																																																																																															UNION ALL (SELECT
	 '2024-03',
	 TO_DATE('20240331',
	 'YYYYMMDD') 
																																																																																																FROM DUMMY)) 
																																																																																														UNION ALL (SELECT
	 '2024-04',
	 TO_DATE('20240430',
	 'YYYYMMDD') 
																																																																																															FROM DUMMY)) 
																																																																																													UNION ALL (SELECT
	 '2024-05',
	 TO_DATE('20240531',
	 'YYYYMMDD') 
																																																																																														FROM DUMMY)) 
																																																																																												UNION ALL (SELECT
	 '2024-06',
	 TO_DATE('20240630',
	 'YYYYMMDD') 
																																																																																													FROM DUMMY)) 
																																																																																											UNION ALL (SELECT
	 '2024-07',
	 TO_DATE('20240731',
	 'YYYYMMDD') 
																																																																																												FROM DUMMY)) 
																																																																																										UNION ALL (SELECT
	 '2024-08',
	 TO_DATE('20240831',
	 'YYYYMMDD') 
																																																																																											FROM DUMMY)) 
																																																																																									UNION ALL (SELECT
	 '2024-09',
	 TO_DATE('20240930',
	 'YYYYMMDD') 
																																																																																										FROM DUMMY)) 
																																																																																								UNION ALL (SELECT
	 '2024-10',
	 TO_DATE('20241031',
	 'YYYYMMDD') 
																																																																																									FROM DUMMY)) 
																																																																																							UNION ALL (SELECT
	 '2024-11',
	 TO_DATE('20241130',
	 'YYYYMMDD') 
																																																																																								FROM DUMMY)) 
																																																																																						UNION ALL (SELECT
	 '2024-12',
	 TO_DATE('20241231',
	 'YYYYMMDD') 
																																																																																							FROM DUMMY)) 
																																																																																					UNION ALL (SELECT
	 '2025-01',
	 TO_DATE('20250131',
	 'YYYYMMDD') 
																																																																																						FROM DUMMY)) 
																																																																																				UNION ALL (SELECT
	 '2025-02',
	 TO_DATE('20250228',
	 'YYYYMMDD') 
																																																																																					FROM DUMMY)) 
																																																																																			UNION ALL (SELECT
	 '2025-03',
	 TO_DATE('20250331',
	 'YYYYMMDD') 
																																																																																				FROM DUMMY)) 
																																																																																		UNION ALL (SELECT
	 '2025-04',
	 TO_DATE('20250430',
	 'YYYYMMDD') 
																																																																																			FROM DUMMY)) 
																																																																																	UNION ALL (SELECT
	 '2025-05',
	 TO_DATE('20250531',
	 'YYYYMMDD') 
																																																																																		FROM DUMMY)) 
																																																																																UNION ALL (SELECT
	 '2025-06',
	 TO_DATE('20250630',
	 'YYYYMMDD') 
																																																																																	FROM DUMMY)) 
																																																																															UNION ALL (SELECT
	 '2025-07',
	 TO_DATE('20250731',
	 'YYYYMMDD') 
																																																																																FROM DUMMY)) 
																																																																														UNION ALL (SELECT
	 '2025-08',
	 TO_DATE('20250831',
	 'YYYYMMDD') 
																																																																															FROM DUMMY)) 
																																																																													UNION ALL (SELECT
	 '2025-09',
	 TO_DATE('20250930',
	 'YYYYMMDD') 
																																																																														FROM DUMMY)) 
																																																																												UNION ALL (SELECT
	 '2025-10',
	 TO_DATE('20251031',
	 'YYYYMMDD') 
																																																																													FROM DUMMY)) 
																																																																											UNION ALL (SELECT
	 '2025-11',
	 TO_DATE('20251130',
	 'YYYYMMDD') 
																																																																												FROM DUMMY)) 
																																																																										UNION ALL (SELECT
	 '2025-12',
	 TO_DATE('20251231',
	 'YYYYMMDD') 
																																																																											FROM DUMMY)) 
																																																																									UNION ALL (SELECT
	 '2026-01',
	 TO_DATE('20260131',
	 'YYYYMMDD') 
																																																																										FROM DUMMY)) 
																																																																								UNION ALL (SELECT
	 '2026-02',
	 TO_DATE('20260228',
	 'YYYYMMDD') 
																																																																									FROM DUMMY)) 
																																																																							UNION ALL (SELECT
	 '2026-03',
	 TO_DATE('20260331',
	 'YYYYMMDD') 
																																																																								FROM DUMMY)) 
																																																																						UNION ALL (SELECT
	 '2026-04',
	 TO_DATE('20260430',
	 'YYYYMMDD') 
																																																																							FROM DUMMY)) 
																																																																					UNION ALL (SELECT
	 '2026-05',
	 TO_DATE('20260531',
	 'YYYYMMDD') 
																																																																						FROM DUMMY)) 
																																																																				UNION ALL (SELECT
	 '2026-06',
	 TO_DATE('20260630',
	 'YYYYMMDD') 
																																																																					FROM DUMMY)) 
																																																																			UNION ALL (SELECT
	 '2026-07',
	 TO_DATE('20260731',
	 'YYYYMMDD') 
																																																																				FROM DUMMY)) 
																																																																		UNION ALL (SELECT
	 '2026-08',
	 TO_DATE('20260831',
	 'YYYYMMDD') 
																																																																			FROM DUMMY)) 
																																																																	UNION ALL (SELECT
	 '2026-09',
	 TO_DATE('20260930',
	 'YYYYMMDD') 
																																																																		FROM DUMMY)) 
																																																																UNION ALL (SELECT
	 '2026-10',
	 TO_DATE('20261031',
	 'YYYYMMDD') 
																																																																	FROM DUMMY)) 
																																																															UNION ALL (SELECT
	 '2026-11',
	 TO_DATE('20261130',
	 'YYYYMMDD') 
																																																																FROM DUMMY)) 
																																																														UNION ALL (SELECT
	 '2026-12',
	 TO_DATE('20261231',
	 'YYYYMMDD') 
																																																															FROM DUMMY)) 
																																																													UNION ALL (SELECT
	 '2027-01',
	 TO_DATE('20270131',
	 'YYYYMMDD') 
																																																														FROM DUMMY)) 
																																																												UNION ALL (SELECT
	 '2027-02',
	 TO_DATE('20270228',
	 'YYYYMMDD') 
																																																													FROM DUMMY)) 
																																																											UNION ALL (SELECT
	 '2027-03',
	 TO_DATE('20270331',
	 'YYYYMMDD') 
																																																												FROM DUMMY)) 
																																																										UNION ALL (SELECT
	 '2027-04',
	 TO_DATE('20270430',
	 'YYYYMMDD') 
																																																											FROM DUMMY)) 
																																																									UNION ALL (SELECT
	 '2027-05',
	 TO_DATE('20270531',
	 'YYYYMMDD') 
																																																										FROM DUMMY)) 
																																																								UNION ALL (SELECT
	 '2027-06',
	 TO_DATE('20270630',
	 'YYYYMMDD') 
																																																									FROM DUMMY)) 
																																																							UNION ALL (SELECT
	 '2027-07',
	 TO_DATE('20270731',
	 'YYYYMMDD') 
																																																								FROM DUMMY)) 
																																																						UNION ALL (SELECT
	 '2027-08',
	 TO_DATE('20270831',
	 'YYYYMMDD') 
																																																							FROM DUMMY)) 
																																																					UNION ALL (SELECT
	 '2027-09',
	 TO_DATE('20250930',
	 'YYYYMMDD') 
																																																						FROM DUMMY)) 
																																																				UNION ALL (SELECT
	 '2027-10',
	 TO_DATE('20251031',
	 'YYYYMMDD') 
																																																					FROM DUMMY)) 
																																																			UNION ALL (SELECT
	 '2027-11',
	 TO_DATE('20251130',
	 'YYYYMMDD') 
																																																				FROM DUMMY)) 
																																																		UNION ALL (SELECT
	 '2027-12',
	 TO_DATE('20251231',
	 'YYYYMMDD') 
																																																			FROM DUMMY)) 
																																																	UNION ALL (SELECT
	 '2028-01',
	 TO_DATE('20260131',
	 'YYYYMMDD') 
																																																		FROM DUMMY)) 
																																																UNION ALL (SELECT
	 '2028-02',
	 TO_DATE('20260228',
	 'YYYYMMDD') 
																																																	FROM DUMMY)) 
																																															UNION ALL (SELECT
	 '2028-03',
	 TO_DATE('20260331',
	 'YYYYMMDD') 
																																																FROM DUMMY)) 
																																														UNION ALL (SELECT
	 '2028-04',
	 TO_DATE('20260430',
	 'YYYYMMDD') 
																																															FROM DUMMY)) 
																																													UNION ALL (SELECT
	 '2028-05',
	 TO_DATE('20260531',
	 'YYYYMMDD') 
																																														FROM DUMMY)) 
																																												UNION ALL (SELECT
	 '2028-06',
	 TO_DATE('20260630',
	 'YYYYMMDD') 
																																													FROM DUMMY)) 
																																											UNION ALL (SELECT
	 '2028-07',
	 TO_DATE('20260731',
	 'YYYYMMDD') 
																																												FROM DUMMY)) 
																																										UNION ALL (SELECT
	 '2028-08',
	 TO_DATE('20260831',
	 'YYYYMMDD') 
																																											FROM DUMMY)) 
																																									UNION ALL (SELECT
	 '2028-09',
	 TO_DATE('20260930',
	 'YYYYMMDD') 
																																										FROM DUMMY)) 
																																								UNION ALL (SELECT
	 '2028-10',
	 TO_DATE('20261031',
	 'YYYYMMDD') 
																																									FROM DUMMY)) 
																																							UNION ALL (SELECT
	 '2028-11',
	 TO_DATE('20261130',
	 'YYYYMMDD') 
																																								FROM DUMMY)) 
																																						UNION ALL (SELECT
	 '2028-12',
	 TO_DATE('20261231',
	 'YYYYMMDD') 
																																							FROM DUMMY)) 
																																					UNION ALL (SELECT
	 '2029-01',
	 TO_DATE('20260131',
	 'YYYYMMDD') 
																																						FROM DUMMY)) 
																																				UNION ALL (SELECT
	 '2029-02',
	 TO_DATE('20260228',
	 'YYYYMMDD') 
																																					FROM DUMMY)) 
																																			UNION ALL (SELECT
	 '2029-03',
	 TO_DATE('20260331',
	 'YYYYMMDD') 
																																				FROM DUMMY)) 
																																		UNION ALL (SELECT
	 '2029-04',
	 TO_DATE('20260430',
	 'YYYYMMDD') 
																																			FROM DUMMY)) 
																																	UNION ALL (SELECT
	 '2029-05',
	 TO_DATE('20260531',
	 'YYYYMMDD') 
																																		FROM DUMMY)) 
																																UNION ALL (SELECT
	 '2029-06',
	 TO_DATE('20260630',
	 'YYYYMMDD') 
																																	FROM DUMMY)) 
																															UNION ALL (SELECT
	 '2029-07',
	 TO_DATE('20260731',
	 'YYYYMMDD') 
																																FROM DUMMY)) 
																														UNION ALL (SELECT
	 '2029-08',
	 TO_DATE('20260831',
	 'YYYYMMDD') 
																															FROM DUMMY)) 
																													UNION ALL (SELECT
	 '2029-09',
	 TO_DATE('20260930',
	 'YYYYMMDD') 
																														FROM DUMMY)) 
																												UNION ALL (SELECT
	 '2029-10',
	 TO_DATE('20261031',
	 'YYYYMMDD') 
																													FROM DUMMY)) 
																											UNION ALL (SELECT
	 '2029-11',
	 TO_DATE('20261130',
	 'YYYYMMDD') 
																												FROM DUMMY)) 
																										UNION ALL (SELECT
	 '2029-12',
	 TO_DATE('20261231',
	 'YYYYMMDD') 
																											FROM DUMMY)) 
																									UNION ALL (SELECT
	 '2030-01',
	 TO_DATE('20270131',
	 'YYYYMMDD') 
																										FROM DUMMY)) 
																								UNION ALL (SELECT
	 '2030-02',
	 TO_DATE('20270228',
	 'YYYYMMDD') 
																									FROM DUMMY)) 
																							UNION ALL (SELECT
	 '2030-03',
	 TO_DATE('20270331',
	 'YYYYMMDD') 
																								FROM DUMMY)) 
																						UNION ALL (SELECT
	 '2030-04',
	 TO_DATE('20270430',
	 'YYYYMMDD') 
																							FROM DUMMY)) 
																					UNION ALL (SELECT
	 '2030-05',
	 TO_DATE('20270531',
	 'YYYYMMDD') 
																						FROM DUMMY)) 
																				UNION ALL (SELECT
	 '2030-06',
	 TO_DATE('20270630',
	 'YYYYMMDD') 
																					FROM DUMMY)) 
																			UNION ALL (SELECT
	 '2030-07',
	 TO_DATE('20270731',
	 'YYYYMMDD') 
																				FROM DUMMY)) 
																		UNION ALL (SELECT
	 '2030-08',
	 TO_DATE('20270831',
	 'YYYYMMDD') 
																			FROM DUMMY)) 
																	UNION ALL (SELECT
	 '2030-09',
	 TO_DATE('20250930',
	 'YYYYMMDD') 
																		FROM DUMMY)) 
																UNION ALL (SELECT
	 '2030-10',
	 TO_DATE('20251031',
	 'YYYYMMDD') 
																	FROM DUMMY)) 
															UNION ALL (SELECT
	 '2030-11',
	 TO_DATE('20251130',
	 'YYYYMMDD') 
																FROM DUMMY)) 
														UNION ALL (SELECT
	 '2030-12',
	 TO_DATE('20251231',
	 'YYYYMMDD') 
															FROM DUMMY)) 
													UNION ALL (SELECT
	 '2031-01',
	 TO_DATE('20260131',
	 'YYYYMMDD') 
														FROM DUMMY)) 
												UNION ALL (SELECT
	 '2031-02',
	 TO_DATE('20260228',
	 'YYYYMMDD') 
													FROM DUMMY)) 
											UNION ALL (SELECT
	 '2031-03',
	 TO_DATE('20260331',
	 'YYYYMMDD') 
												FROM DUMMY)) 
										UNION ALL (SELECT
	 '2031-04',
	 TO_DATE('20260430',
	 'YYYYMMDD') 
											FROM DUMMY)) 
									UNION ALL (SELECT
	 '2031-05',
	 TO_DATE('20260531',
	 'YYYYMMDD') 
										FROM DUMMY)) 
								UNION ALL (SELECT
	 '2031-06',
	 TO_DATE('20260630',
	 'YYYYMMDD') 
									FROM DUMMY)) 
							UNION ALL (SELECT
	 '2031-07',
	 TO_DATE('20260731',
	 'YYYYMMDD') 
								FROM DUMMY)) 
						UNION ALL (SELECT
	 '2031-08',
	 TO_DATE('20260831',
	 'YYYYMMDD') 
							FROM DUMMY)) 
					UNION ALL (SELECT
	 '2031-09',
	 TO_DATE('20260930',
	 'YYYYMMDD') 
						FROM DUMMY)) 
				UNION ALL (SELECT
	 '2031-10',
	 TO_DATE('20261031',
	 'YYYYMMDD') 
					FROM DUMMY)) 
			UNION ALL (SELECT
	 '2031-11',
	 TO_DATE('20261130',
	 'YYYYMMDD') 
				FROM DUMMY)) 
		UNION ALL (SELECT
	 '2031-12',
	 TO_DATE('20261231',
	 'YYYYMMDD') 
			FROM DUMMY))),
	 "BASE" AS (SELECT
	 m."Month",
	 T2."ItmsGrpNam",
	 T1."ItemCode",
	 T1."ItemName",
	 T0."WhsCode",
	 T0."BatchNum",
	 CASE WHEN T0."Direction" = 1 
	THEN -T0."Quantity" 
	ELSE T0."Quantity" 
	END AS "Quantity",
	 CASE WHEN T3."CostTotal" > 0 
	THEN ROUND((T3."CostTotal" / NULLIF(T3."Quantity",
	0)),
	2) 
	ELSE 0 
	END AS "Cost Value",
	 CASE WHEN SUBSTRING(T0."BatchNum",
	 1,
	 1) = 'M' 
	THEN T4."U_AvgButtonsPerRod" 
	ELSE 1 
	END AS "AvgButtonsPerRod" 
	FROM months m JOIN IBT1 T0 ON T0."DocDate" <= m."Cutoff" 
	AND T0."Direction" IN (0,
	1) JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode" JOIN OITB T2 ON T1."ItmsGrpCod" = T2."ItmsGrpCod" JOIN OBTN T3 ON T0."BatchNum" = T3."DistNumber" 
	AND T0."ItemCode" = T3."ItemCode" JOIN "@CT_PF_OBOM" T4 ON T0."ItemCode" = T4."U_ItemCode" 
	AND T3."U_Revision" = T4."U_Revision" 
	WHERE T2."ItmsGrpNam" IN ('SEMI-FINISHED MADE')),
	 "BATCH_AGG" AS (SELECT
	 "Month",
	 "ItmsGrpNam",
	 "ItemCode",
	 "ItemName",
	 "BatchNum",
	 "AvgButtonsPerRod",
	 SUM("Quantity") AS "SumQty",
	 ROUND(SUM("Quantity") * MAX("Cost Value")) AS "Value" 
	FROM base 
	GROUP BY "Month",
	 "ItmsGrpNam",
	 "ItemCode",
	 "ItemName",
	 "BatchNum",
	 "AvgButtonsPerRod") SELECT
	 "Month",
	 "ItemCode",
	 "ItemName",
	 SUM("Value") AS "Total Stock Value",
	 SUM("SumQty" * "AvgButtonsPerRod") AS "Total Stock Qty" 
FROM batch_agg 
GROUP BY "Month",
	 "ItemCode",
	 "ItemName" WITH READ ONLY
