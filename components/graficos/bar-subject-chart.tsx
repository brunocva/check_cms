'use client'

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import type { PerformanceEntry } from '@/lib/utils/metrics'

// Desempenho (% de acerto) agrupado por matéria.
export function BarSubjectChart({ data }: { data: PerformanceEntry[] }) {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <BarChart data={data} margin={{ top: 8, right: 16, left: -16, bottom: 24 }}>
        <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
        <XAxis
          dataKey="name"
          tick={{ fontSize: 12 }}
          stroke="currentColor"
          className="text-muted-foreground"
          interval={0}
          angle={-15}
          textAnchor="end"
          height={50}
        />
        <YAxis domain={[0, 100]} tick={{ fontSize: 12 }} stroke="currentColor" className="text-muted-foreground" />
        <Tooltip
          formatter={(value, _name, item) => {
            const entry = item.payload as PerformanceEntry | undefined
            return [`${value}% (${entry?.correct ?? 0}/${entry?.total ?? 0})`, 'Acerto']
          }}
          contentStyle={{ borderRadius: 8, fontSize: 12 }}
        />
        <Bar dataKey="accuracy" fill="#6366f1" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  )
}
