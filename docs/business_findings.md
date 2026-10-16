# Business findings and interpretation

## 1. Product catalog and supplier coverage
Q01 counts 12,000 products across eight categories. Exhaust has 1,557, the highest count. Q02 joins products to categories and suppliers, giving catalog coverage by supplier country; supplier country should not be interpreted as country of manufacture. Q06 sums list prices of **active** products per supplier; this is a portfolio pricing metric rather than sales or stock value.

## 2. Inventory
Q03 aggregates warehouse inventory to product level. On-hand quantity totals **3,754,902** and reserved quantity totals **618,392**, leaving **3,136,510** units as calculated availability. The 957 products with zero on-hand inventory may warrant replenishment review, but stockout or lost-sales conclusions require demand and availability context.

## 3. Sales performance
For Q04, Q08, Q09, Q10, and Q11, sales are computed only from **Completed/Shipped** parent orders and **Fulfilled** lines, after line-level discounts. The baseline is **7,350,764.60** in calculated sales value. The top 20 products (Q04) contribute **174,718.70** (approximately 2.38%). Electrical is the highest sales-share category (**13.71%**), while Cooling is the lowest (**11.60%**). Product catalog size alone does not determine sales share: Exhaust has the most products but Electrical has the highest sales value.

Q08 compares monthly sales with `LAG()`, while Q10 accumulates monthly sales using a windowed `SUM()`. The cumulative figure rises with positive monthly sales; that alone does not prove accelerating growth. Summing individually rounded monthly figures may differ from the unrounded cumulative value by 0.01.

## 4. Returns
Q05 measures order-line return rate, not returned units or whole orders. **2,990** of **60,000** order lines are marked Returned, or approximately **4.98%**. Interior has the highest rate (**5.36%**) and Electrical the lowest (**4.66%**). The differences suggest investigation priorities, not evidence of defects or root causes.

## 5. Pricing and supplier portfolio
Q07 identifies **4,079** products priced above their own category average (approximately **33.99%** of the catalog). Q12 selects each supplier's most expensive active product, using `ROW_NUMBER()` to choose exactly one product per supplier. These are list-price comparisons, not measures of profitability.

## Recommended next business questions
- How does available inventory compare with sales demand for the highest-performing products?
- Which categories combine high returns with high sales value?
- Are high-list-price products also high-performing in realized sales?

## Interpretation safeguards
The dataset is synthetic; do not present any results as real company financial performance. The defined eligible sales measure is not accounting revenue. Supplier location is not manufacturing origin. Return-rate denominators include all order lines regardless of parent order status. No causal explanations are established by the available data.
